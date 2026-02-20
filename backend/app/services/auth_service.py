"""
Authentication service: registration, login, OTP, password reset.
"""

import random
import string
from datetime import datetime, timedelta, timezone

from sqlalchemy.ext.asyncio import AsyncSession

from app.config import get_settings
from app.core.exceptions import (
    BadRequestException,
    ConflictException,
    CredentialsException,
    NotFoundException,
    OTPExpiredException,
    OTPInvalidException,
)
from app.core.security import (
    create_access_token,
    create_refresh_token,
    hash_password,
    verify_password,
    verify_refresh_token,
)
from app.models.otp import OTPCode
from app.models.user import User, UserRole
from app.repositories.otp_repository import OTPRepository
from app.repositories.user_repository import UserRepository
from app.schemas.auth import (
    LoginRequest,
    OTPResponse,
    PasswordResetConfirm,
    RegisterRequest,
    RegisterResponse,
    TokenResponse,
)

settings = get_settings()


class AuthService:
    """Business logic for authentication operations."""

    def __init__(self, db: AsyncSession):
        self.db = db
        self.user_repo = UserRepository(db)
        self.otp_repo = OTPRepository(db)

    # ── Registration ─────────────────────────────────────────
    async def register(self, data: RegisterRequest) -> RegisterResponse:
        """Register a new user account."""
        # Check duplicate email
        existing = await self.user_repo.get_by_email(data.email)
        if existing:
            raise ConflictException(detail="Email already registered")

        # Check duplicate phone
        if data.phone:
            existing_phone = await self.user_repo.get_by_phone(data.phone)
            if existing_phone:
                raise ConflictException(detail="Phone number already registered")

        # Create user
        user = User(
            email=data.email,
            full_name=data.full_name,
            hashed_password=hash_password(data.password),
            phone=data.phone,
            role=data.role,
            is_verified=False,
            is_active=True,
        )
        user = await self.user_repo.create(user)

        # Generate and store OTP
        await self._generate_otp(user.id, purpose="verification")

        return RegisterResponse(
            id=user.id,
            email=user.email,
            full_name=user.full_name,
            role=user.role.value,
            is_verified=user.is_verified,
        )

    # ── OTP Verification ────────────────────────────────────
    async def verify_otp(self, email: str, code: str) -> TokenResponse:
        """Verify OTP code and activate account."""
        user = await self.user_repo.get_by_email(email)
        if not user:
            raise NotFoundException(detail="User not found")

        otp = await self.otp_repo.get_latest_valid(user.id, purpose="verification")
        if not otp:
            raise OTPInvalidException(detail="No valid OTP found. Please request a new one.")

        if otp.is_expired:
            raise OTPExpiredException()

        if otp.code != code:
            raise OTPInvalidException()

        # Mark OTP as used and verify user
        await self.otp_repo.mark_used(otp)
        user.is_verified = True
        await self.user_repo.update(user)

        # Return tokens
        return self._create_token_response(user)

    # ── Resend OTP ───────────────────────────────────────────
    async def resend_otp(self, email: str) -> OTPResponse:
        """Resend OTP to user's email."""
        user = await self.user_repo.get_by_email(email)
        if not user:
            raise NotFoundException(detail="User not found")

        if user.is_verified:
            raise BadRequestException(detail="Account is already verified")

        # Invalidate old OTPs and generate new one
        await self.otp_repo.invalidate_all(user.id, purpose="verification")
        otp_code = await self._generate_otp(user.id, purpose="verification")

        response = OTPResponse(message="OTP sent successfully")
        if settings.DEBUG:
            response.otp_code = otp_code  # Only in dev mode
        return response

    # ── Login ────────────────────────────────────────────────
    async def login(self, data: LoginRequest) -> TokenResponse:
        """Authenticate user and return JWT tokens."""
        user = await self.user_repo.get_by_email(data.email)
        if not user:
            raise CredentialsException(detail="Invalid email or password")

        if not verify_password(data.password, user.hashed_password):
            raise CredentialsException(detail="Invalid email or password")

        if not user.is_active:
            raise CredentialsException(detail="Account is deactivated")

        if not user.is_verified:
            raise BadRequestException(
                detail="Account not verified. Please verify your OTP first."
            )

        return self._create_token_response(user)

    # ── Token Refresh ────────────────────────────────────────
    async def refresh_token(self, refresh_token_str: str) -> TokenResponse:
        """Generate new access token from refresh token."""
        payload = verify_refresh_token(refresh_token_str)
        if not payload:
            raise CredentialsException(detail="Invalid or expired refresh token")

        user_id = payload.get("sub")
        if not user_id:
            raise CredentialsException(detail="Invalid token payload")

        user = await self.user_repo.get_by_id(user_id)
        if not user or not user.is_active:
            raise CredentialsException(detail="User not found or inactive")

        return self._create_token_response(user)

    # ── Password Reset Request ───────────────────────────────
    async def request_password_reset(self, email: str) -> OTPResponse:
        """Send password reset OTP."""
        user = await self.user_repo.get_by_email(email)
        if not user:
            # Don't reveal if email exists — but for dev/demo we raise
            raise NotFoundException(detail="User not found")

        # Invalidate old reset OTPs and generate new one
        await self.otp_repo.invalidate_all(user.id, purpose="password_reset")
        otp_code = await self._generate_otp(user.id, purpose="password_reset")

        response = OTPResponse(message="Password reset OTP sent")
        if settings.DEBUG:
            response.otp_code = otp_code
        return response

    # ── Password Reset Confirm ───────────────────────────────
    async def confirm_password_reset(self, data: PasswordResetConfirm) -> dict:
        """Verify reset OTP and set new password."""
        user = await self.user_repo.get_by_email(data.email)
        if not user:
            raise NotFoundException(detail="User not found")

        otp = await self.otp_repo.get_latest_valid(user.id, purpose="password_reset")
        if not otp:
            raise OTPInvalidException(detail="No valid reset OTP found")

        if otp.is_expired:
            raise OTPExpiredException()

        if otp.code != data.code:
            raise OTPInvalidException()

        # Update password
        await self.otp_repo.mark_used(otp)
        user.hashed_password = hash_password(data.new_password)
        await self.user_repo.update(user)

        return {"message": "Password reset successful. You can now login with your new password."}

    # ── Helpers ──────────────────────────────────────────────
    async def _generate_otp(self, user_id: str, purpose: str = "verification") -> str:
        """Generate a random OTP code and store it."""
        code = "".join(random.choices(string.digits, k=settings.OTP_LENGTH))

        otp = OTPCode(
            user_id=user_id,
            code=code,
            purpose=purpose,
            expires_at=datetime.now(timezone.utc) + timedelta(minutes=settings.OTP_EXPIRE_MINUTES),
        )
        await self.otp_repo.create(otp)

        # In production, send via SMS/email service here
        # For now, mock: log to console
        print(f"[MOCK OTP] User {user_id} | Purpose: {purpose} | Code: {code}")
        return code

    def _create_token_response(self, user: User) -> TokenResponse:
        """Create JWT token pair for a user."""
        token_data = {"sub": user.id, "role": user.role.value}
        access_token = create_access_token(token_data)
        refresh_token = create_refresh_token(token_data)

        return TokenResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
            user_id=user.id,
            role=user.role.value,
        )

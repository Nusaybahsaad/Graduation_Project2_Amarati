"""
Authentication routes: register, login, OTP, token refresh, password reset, logout.
"""

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.dependencies import get_current_user
from app.models.user import User
from app.schemas.auth import (
    LoginRequest,
    LogoutResponse,
    MessageResponse,
    OTPResendRequest,
    OTPResponse,
    OTPVerifyRequest,
    PasswordResetConfirm,
    PasswordResetRequest,
    RefreshTokenRequest,
    RegisterRequest,
    RegisterResponse,
    TokenResponse,
)
from app.schemas.user import UserResponse
from app.services.auth_service import AuthService

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post("/register", response_model=RegisterResponse, status_code=201)
async def register(
    data: RegisterRequest,
    db: AsyncSession = Depends(get_db),
):
    """
    Register a new user account.
    An OTP code will be generated for verification (logged to console in dev mode).
    """
    service = AuthService(db)
    return await service.register(data)


@router.post("/verify-otp", response_model=TokenResponse)
async def verify_otp(
    data: OTPVerifyRequest,
    db: AsyncSession = Depends(get_db),
):
    """
    Verify OTP code to activate account.
    Returns JWT tokens on success.
    """
    service = AuthService(db)
    return await service.verify_otp(data.email, data.code)


@router.post("/resend-otp", response_model=OTPResponse)
async def resend_otp(
    data: OTPResendRequest,
    db: AsyncSession = Depends(get_db),
):
    """
    Resend OTP verification code.
    In debug mode, the OTP code is included in the response.
    """
    service = AuthService(db)
    return await service.resend_otp(data.email)


@router.post("/login", response_model=TokenResponse)
async def login(
    data: LoginRequest,
    db: AsyncSession = Depends(get_db),
):
    """
    Login with email and password.
    Returns JWT access and refresh tokens.
    """
    service = AuthService(db)
    return await service.login(data)


@router.post("/refresh", response_model=TokenResponse)
async def refresh_token(
    data: RefreshTokenRequest,
    db: AsyncSession = Depends(get_db),
):
    """
    Refresh access token using a valid refresh token.
    """
    service = AuthService(db)
    return await service.refresh_token(data.refresh_token)


@router.get("/me", response_model=UserResponse)
async def get_current_user_profile(
    current_user: User = Depends(get_current_user),
):
    """
    Get the currently authenticated user's profile.
    Requires valid access token.
    """
    return UserResponse.model_validate(current_user)


@router.post("/request-password-reset", response_model=OTPResponse)
async def request_password_reset(
    data: PasswordResetRequest,
    db: AsyncSession = Depends(get_db),
):
    """
    Request a password reset OTP.
    In debug mode, the OTP code is included in the response.
    """
    service = AuthService(db)
    return await service.request_password_reset(data.email)


@router.post("/confirm-password-reset", response_model=MessageResponse)
async def confirm_password_reset(
    data: PasswordResetConfirm,
    db: AsyncSession = Depends(get_db),
):
    """
    Confirm password reset with OTP code and new password.
    """
    service = AuthService(db)
    result = await service.confirm_password_reset(data)
    return MessageResponse(**result)


@router.post("/logout", response_model=LogoutResponse)
async def logout(
    current_user: User = Depends(get_current_user),
):
    """
    Logout current user.
    Client should discard tokens. (Server-side token blacklisting
    can be added in production with Redis.)
    """
    return LogoutResponse()

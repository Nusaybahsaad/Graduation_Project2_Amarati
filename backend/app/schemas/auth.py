"""
Authentication schemas: registration, login, tokens, OTP.
"""

from pydantic import BaseModel, EmailStr, Field

from app.models.user import UserRole


# ── Registration ─────────────────────────────────────────────────
class RegisterRequest(BaseModel):
    """User registration payload."""
    email: EmailStr
    password: str = Field(..., min_length=8, max_length=128)
    full_name: str = Field(..., min_length=2, max_length=255)
    phone: str | None = Field(None, max_length=20)
    role: UserRole = UserRole.TENANT


class RegisterResponse(BaseModel):
    """Registration success response."""
    id: str
    email: str
    full_name: str
    role: str
    is_verified: bool
    message: str = "Registration successful. Please verify your account with the OTP sent."


# ── Login ────────────────────────────────────────────────────────
class LoginRequest(BaseModel):
    """Login payload — accepts email."""
    email: EmailStr
    password: str


class TokenResponse(BaseModel):
    """JWT token response."""
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int  # seconds
    user_id: str
    role: str


# ── Token Refresh ────────────────────────────────────────────────
class RefreshTokenRequest(BaseModel):
    """Refresh token payload."""
    refresh_token: str


# ── OTP ──────────────────────────────────────────────────────────
class OTPVerifyRequest(BaseModel):
    """OTP verification payload."""
    email: EmailStr
    code: str = Field(..., min_length=4, max_length=10)


class OTPResendRequest(BaseModel):
    """Request to resend OTP."""
    email: EmailStr


class OTPResponse(BaseModel):
    """OTP operation response."""
    message: str
    # In dev mode we include the OTP for testing
    otp_code: str | None = None


# ── Password Reset ───────────────────────────────────────────────
class PasswordResetRequest(BaseModel):
    """Request a password reset OTP."""
    email: EmailStr


class PasswordResetConfirm(BaseModel):
    """Confirm password reset with OTP and new password."""
    email: EmailStr
    code: str = Field(..., min_length=4, max_length=10)
    new_password: str = Field(..., min_length=8, max_length=128)


# ── Logout ───────────────────────────────────────────────────────
class LogoutResponse(BaseModel):
    """Logout response."""
    message: str = "Successfully logged out"


# ── General ──────────────────────────────────────────────────────
class MessageResponse(BaseModel):
    """Generic message response."""
    message: str

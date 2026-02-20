"""
User schemas: response models and update payloads.
"""

from datetime import datetime
from typing import Optional

from pydantic import BaseModel, EmailStr, Field


class UserResponse(BaseModel):
    """User data returned in API responses."""
    id: str
    email: str
    phone: Optional[str] = None
    full_name: str
    role: str
    is_active: bool
    is_verified: bool
    avatar_url: Optional[str] = None
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}


class UserUpdate(BaseModel):
    """Payload for updating user profile."""
    full_name: Optional[str] = Field(None, min_length=2, max_length=255)
    phone: Optional[str] = Field(None, max_length=20)
    avatar_url: Optional[str] = None


class UserListResponse(BaseModel):
    """Paginated user list."""
    users: list[UserResponse]
    total: int
    page: int
    page_size: int


class ChangePasswordRequest(BaseModel):
    """Payload for changing password (authenticated)."""
    current_password: str
    new_password: str = Field(..., min_length=8, max_length=128)

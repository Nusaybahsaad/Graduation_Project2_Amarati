"""
User management routes: list, get, update, deactivate.
"""

from typing import Optional

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.rbac import RoleChecker
from app.database import get_db
from app.dependencies import get_current_active_user, get_current_user
from app.models.user import User, UserRole
from app.schemas.user import (
    ChangePasswordRequest,
    UserListResponse,
    UserResponse,
    UserUpdate,
)
from app.services.user_service import UserService

router = APIRouter(prefix="/users", tags=["Users"])


@router.get("/", response_model=UserListResponse)
async def list_users(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    role: Optional[UserRole] = Query(None),
    is_active: Optional[bool] = Query(None),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
    _=Depends(RoleChecker(["admin"])),
):
    """
    List all users with pagination and filters.
    Admin-only endpoint.
    """
    service = UserService(db)
    skip = (page - 1) * page_size
    users, total = await service.get_users(
        skip=skip, limit=page_size, role=role, is_active=is_active
    )
    return UserListResponse(
        users=[UserResponse.model_validate(u) for u in users],
        total=total,
        page=page,
        page_size=page_size,
    )


@router.get("/{user_id}", response_model=UserResponse)
async def get_user(
    user_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Get a user by ID.
    Users can view their own profile. Admins can view any user.
    """
    # Non-admin users can only view their own profile
    if current_user.role != UserRole.ADMIN and current_user.id != user_id:
        from app.core.exceptions import ForbiddenException
        raise ForbiddenException(detail="You can only view your own profile")

    service = UserService(db)
    user = await service.get_user_by_id(user_id)
    return UserResponse.model_validate(user)


@router.put("/{user_id}", response_model=UserResponse)
async def update_user(
    user_id: str,
    data: UserUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Update user profile.
    Users can update their own profile. Admins can update any user.
    """
    if current_user.role != UserRole.ADMIN and current_user.id != user_id:
        from app.core.exceptions import ForbiddenException
        raise ForbiddenException(detail="You can only update your own profile")

    service = UserService(db)
    user = await service.update_user(user_id, data)
    return UserResponse.model_validate(user)


@router.post("/{user_id}/change-password")
async def change_password(
    user_id: str,
    data: ChangePasswordRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Change password for a user.
    Users can only change their own password.
    """
    if current_user.id != user_id:
        from app.core.exceptions import ForbiddenException
        raise ForbiddenException(detail="You can only change your own password")

    service = UserService(db)
    return await service.change_password(user_id, data)


@router.delete("/{user_id}", response_model=UserResponse)
async def deactivate_user(
    user_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
    _=Depends(RoleChecker(["admin"])),
):
    """
    Deactivate (soft-delete) a user. Admin-only.
    """
    service = UserService(db)
    user = await service.deactivate_user(user_id)
    return UserResponse.model_validate(user)

"""
User service: user CRUD and profile management.
"""

from typing import Optional

from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import CredentialsException, NotFoundException
from app.core.security import hash_password, verify_password
from app.models.user import User, UserRole
from app.repositories.user_repository import UserRepository
from app.schemas.user import ChangePasswordRequest, UserResponse, UserUpdate


class UserService:
    """Business logic for user management."""

    def __init__(self, db: AsyncSession):
        self.db = db
        self.user_repo = UserRepository(db)

    async def get_user_by_id(self, user_id: str) -> User:
        """Get a user by ID or raise 404."""
        user = await self.user_repo.get_by_id(user_id)
        if not user:
            raise NotFoundException(detail="User not found")
        return user

    async def get_users(
        self,
        skip: int = 0,
        limit: int = 20,
        role: Optional[UserRole] = None,
        is_active: Optional[bool] = None,
    ) -> tuple[list[User], int]:
        """Get paginated user list with optional filters."""
        return await self.user_repo.get_all(
            skip=skip, limit=limit, role=role, is_active=is_active
        )

    async def update_user(self, user_id: str, data: UserUpdate) -> User:
        """Update user profile fields."""
        user = await self.get_user_by_id(user_id)

        update_data = data.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(user, field, value)

        return await self.user_repo.update(user)

    async def change_password(
        self, user_id: str, data: ChangePasswordRequest
    ) -> dict:
        """Change user password (requires current password)."""
        user = await self.get_user_by_id(user_id)

        if not verify_password(data.current_password, user.hashed_password):
            raise CredentialsException(detail="Current password is incorrect")

        user.hashed_password = hash_password(data.new_password)
        await self.user_repo.update(user)

        return {"message": "Password changed successfully"}

    async def deactivate_user(self, user_id: str) -> User:
        """Deactivate (soft-delete) a user account."""
        user = await self.get_user_by_id(user_id)
        return await self.user_repo.deactivate(user)

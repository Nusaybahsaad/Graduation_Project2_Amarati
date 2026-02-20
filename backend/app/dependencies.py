"""
FastAPI dependencies for dependency injection.
"""

from fastapi import Depends, Request
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import CredentialsException
from app.core.security import verify_access_token
from app.database import get_db
from app.models.user import User
from app.repositories.user_repository import UserRepository


async def get_current_user(
    request: Request,
    db: AsyncSession = Depends(get_db),
) -> User:
    """
    FastAPI dependency that returns the currently authenticated user.
    First checks request.state (set by middleware), then falls back
    to extracting from Authorization header.
    """
    # Try from middleware
    user = getattr(request.state, "user", None)
    if user:
        return user

    # Fallback: extract from header
    auth_header = request.headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        raise CredentialsException()

    token = auth_header.split(" ", 1)[1]
    payload = verify_access_token(token)
    if not payload:
        raise CredentialsException()

    user_id = payload.get("sub")
    if not user_id:
        raise CredentialsException()

    user_repo = UserRepository(db)
    user = await user_repo.get_by_id(user_id)
    if not user or not user.is_active:
        raise CredentialsException(detail="User not found or inactive")

    # Set on request.state for RBAC checker
    request.state.user = user
    return user


async def get_current_active_user(
    current_user: User = Depends(get_current_user),
) -> User:
    """Dependency that ensures the user is active."""
    if not current_user.is_active:
        raise CredentialsException(detail="Inactive user")
    return current_user

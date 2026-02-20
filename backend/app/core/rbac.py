"""
Role-Based Access Control (RBAC) for FastAPI.
Provides dependency-based authorization using role checks.
"""

from typing import List

from fastapi import Depends, Request

from app.core.exceptions import ForbiddenException


class RoleChecker:
    """
    FastAPI dependency that checks if the current user has one of
    the allowed roles.

    Usage:
        @router.get("/admin-only", dependencies=[Depends(RoleChecker(["admin"]))])
        async def admin_endpoint(): ...

    Or in function parameters:
        async def endpoint(
            _=Depends(RoleChecker(["owner", "admin"])),
            current_user=Depends(get_current_user),
        ): ...
    """

    def __init__(self, allowed_roles: List[str]):
        self.allowed_roles = allowed_roles

    async def __call__(self, request: Request) -> None:
        # The user is set on request.state by the get_current_user dependency
        user = getattr(request.state, "user", None)
        if user is None:
            raise ForbiddenException(detail="Authentication required")

        if user.role.value not in self.allowed_roles:
            raise ForbiddenException(
                detail=f"Role '{user.role.value}' is not authorized. "
                f"Required: {', '.join(self.allowed_roles)}"
            )


# ── Permission matrix ──────────────────────────────────────────
# Defines what each role can access (for reference & middleware)
ROLE_PERMISSIONS = {
    "admin": {
        "users": ["create", "read", "update", "delete"],
        "properties": ["create", "read", "update", "delete"],
        "units": ["create", "read", "update", "delete"],
        "maintenance": ["create", "read", "update", "delete", "assign"],
        "providers": ["create", "read", "update", "delete", "verify"],
    },
    "owner": {
        "properties": ["create", "read", "update"],
        "units": ["create", "read", "update"],
        "maintenance": ["read", "update", "assign"],
        "providers": ["read"],
        "tenants": ["read", "assign"],
    },
    "tenant": {
        "properties": ["read"],
        "units": ["read"],
        "maintenance": ["create", "read"],
        "providers": ["read"],
    },
    "supervisor": {
        "properties": ["read", "update"],
        "units": ["read", "update"],
        "maintenance": ["read", "update", "assign"],
        "providers": ["read"],
    },
    "provider": {
        "maintenance": ["read", "update"],
        "providers": ["read", "update_self"],
    },
}

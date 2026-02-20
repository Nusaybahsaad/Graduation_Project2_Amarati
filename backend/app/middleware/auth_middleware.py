"""
Authentication middleware: extracts JWT from requests
and sets current user on request.state.
"""

from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request

from app.core.security import verify_access_token
from app.database import async_session_factory
from app.repositories.user_repository import UserRepository


# Paths that don't require authentication
PUBLIC_PATHS = {
    "/",
    "/health",
    "/docs",
    "/redoc",
    "/openapi.json",
    "/api/v1/auth/register",
    "/api/v1/auth/login",
    "/api/v1/auth/refresh",
    "/api/v1/auth/verify-otp",
    "/api/v1/auth/resend-otp",
    "/api/v1/auth/request-password-reset",
    "/api/v1/auth/confirm-password-reset",
}


class AuthMiddleware(BaseHTTPMiddleware):
    """
    Middleware that extracts JWT bearer token from Authorization header,
    verifies it, and sets request.state.user for downstream handlers.

    Public paths are skipped.
    """

    async def dispatch(self, request: Request, call_next):
        # Skip public paths
        if request.url.path in PUBLIC_PATHS:
            return await call_next(request)

        # Skip OPTIONS (CORS preflight)
        if request.method == "OPTIONS":
            return await call_next(request)

        # Extract token
        auth_header = request.headers.get("Authorization")
        if auth_header and auth_header.startswith("Bearer "):
            token = auth_header.split(" ", 1)[1]
            payload = verify_access_token(token)

            if payload:
                user_id = payload.get("sub")
                if user_id:
                    # Fetch user from DB
                    async with async_session_factory() as session:
                        user_repo = UserRepository(session)
                        user = await user_repo.get_by_id(user_id)
                        if user and user.is_active:
                            request.state.user = user

        response = await call_next(request)
        return response

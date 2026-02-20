"""
OTP repository: database operations for OTP codes.
"""

from typing import Optional

from sqlalchemy import select, and_
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.otp import OTPCode


class OTPRepository:
    """Data access layer for OTP codes."""

    def __init__(self, db: AsyncSession):
        self.db = db

    async def create(self, otp: OTPCode) -> OTPCode:
        """Insert a new OTP code."""
        self.db.add(otp)
        await self.db.flush()
        await self.db.refresh(otp)
        return otp

    async def get_latest_valid(
        self,
        user_id: str,
        purpose: str = "verification",
    ) -> Optional[OTPCode]:
        """
        Get the latest unused, non-expired OTP for a user.
        """
        result = await self.db.execute(
            select(OTPCode)
            .where(
                and_(
                    OTPCode.user_id == user_id,
                    OTPCode.purpose == purpose,
                    OTPCode.is_used == False,  # noqa: E712
                )
            )
            .order_by(OTPCode.created_at.desc())
            .limit(1)
        )
        return result.scalar_one_or_none()

    async def mark_used(self, otp: OTPCode) -> OTPCode:
        """Mark an OTP as used."""
        otp.is_used = True
        await self.db.flush()
        await self.db.refresh(otp)
        return otp

    async def invalidate_all(self, user_id: str, purpose: str = "verification") -> None:
        """Mark all unused OTPs for a user/purpose as used."""
        result = await self.db.execute(
            select(OTPCode).where(
                and_(
                    OTPCode.user_id == user_id,
                    OTPCode.purpose == purpose,
                    OTPCode.is_used == False,  # noqa: E712
                )
            )
        )
        otps = result.scalars().all()
        for otp in otps:
            otp.is_used = True
        await self.db.flush()

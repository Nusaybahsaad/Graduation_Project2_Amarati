"""
Unit management service for Amarati.
"""

from typing import List, Optional
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.unit import Unit
from app.repositories.unit_repository import UnitRepository
from app.schemas.unit import UnitCreate, UnitUpdate
from app.core.exceptions import NotFoundException


class UnitService:
    """Service for unit-related business logic."""

    def __init__(self, db: AsyncSession):
        self.repo = UnitRepository(db)

    async def create_unit(self, unit_in: UnitCreate) -> Unit:
        """Create a new unit."""
        return await self.repo.create(unit_in)

    async def get_unit(self, unit_id: str) -> Unit:
        """Get unit by ID or raise 404."""
        db_unit = await self.repo.get_by_id(unit_id)
        if not db_unit:
            raise NotFoundException(f"Unit with ID {unit_id} not found")
        return db_unit

    async def list_units_by_property(
        self, 
        property_id: str,
        skip: int = 0, 
        limit: int = 100
    ) -> List[Unit]:
        """List units for a property with pagination."""
        return await self.repo.get_multi_by_property(
            property_id=property_id, skip=skip, limit=limit
        )

    async def update_unit(self, unit_id: str, unit_in: UnitUpdate) -> Unit:
        """Update unit details."""
        db_unit = await self.get_unit(unit_id)
        return await self.repo.update(db_unit, unit_in)

    async def delete_unit(self, unit_id: str) -> bool:
        """Delete a unit."""
        # Ensure it exists
        await self.get_unit(unit_id)
        return await self.repo.delete(unit_id)

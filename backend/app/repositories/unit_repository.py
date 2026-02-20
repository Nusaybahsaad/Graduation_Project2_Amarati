"""
Unit repository for Amarati.
"""

from typing import List, Optional
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.unit import Unit
from app.schemas.unit import UnitCreate, UnitUpdate


class UnitRepository:
    """Repository for Unit data operations."""

    def __init__(self, db: AsyncSession):
        self.db = db

    async def create(self, unit_in: UnitCreate) -> Unit:
        """Create a new unit."""
        db_unit = Unit(**unit_in.model_dump())
        self.db.add(db_unit)
        await self.db.commit()
        await self.db.refresh(db_unit)
        return db_unit

    async def get_by_id(self, unit_id: str) -> Optional[Unit]:
        """Get unit by ID."""
        result = await self.db.execute(select(Unit).where(Unit.id == unit_id))
        return result.scalars().first()

    async def get_multi_by_property(
        self, 
        property_id: str,
        skip: int = 0, 
        limit: int = 100
    ) -> List[Unit]:
        """Get multiple units for a specific property."""
        query = select(Unit).where(Unit.property_id == property_id)
        result = await self.db.execute(query.offset(skip).limit(limit))
        return result.scalars().all()

    async def update(self, db_unit: Unit, unit_in: UnitUpdate) -> Unit:
        """Update a unit."""
        update_data = unit_in.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(db_unit, field, value)
        
        await self.db.commit()
        await self.db.refresh(db_unit)
        return db_unit

    async def delete(self, unit_id: str) -> bool:
        """Delete a unit."""
        db_unit = await self.get_by_id(unit_id)
        if not db_unit:
            return False
        await self.db.delete(db_unit)
        await self.db.commit()
        return True

    async def count_by_property(self, property_id: str) -> int:
        """Count units in a property."""
        query = select(func.count()).where(Unit.property_id == property_id)
        result = await self.db.execute(query)
        return result.scalar() or 0

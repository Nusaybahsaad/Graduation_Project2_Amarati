"""
Property repository for Amarati.
"""

from typing import List, Optional
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.property import Property
from app.schemas.property import PropertyCreate, PropertyUpdate


class PropertyRepository:
    """Repository for Property data operations."""

    def __init__(self, db: AsyncSession):
        self.db = db

    async def create(self, property_in: PropertyCreate) -> Property:
        """Create a new property."""
        db_property = Property(**property_in.model_dump())
        self.db.add(db_property)
        await self.db.commit()
        await self.db.refresh(db_property)
        return db_property

    async def get_by_id(self, property_id: str) -> Optional[Property]:
        """Get property by ID."""
        result = await self.db.execute(select(Property).where(Property.id == property_id))
        return result.scalars().first()

    async def get_multi(
        self, 
        skip: int = 0, 
        limit: int = 100,
        owner_id: Optional[str] = None,
        supervisor_id: Optional[str] = None,
        city: Optional[str] = None
    ) -> List[Property]:
        """Get multiple properties with optional filters."""
        query = select(Property)
        if owner_id:
            query = query.where(Property.owner_id == owner_id)
        if supervisor_id:
            query = query.where(Property.supervisor_id == supervisor_id)
        if city:
            query = query.where(Property.city == city)
        
        result = await self.db.execute(query.offset(skip).limit(limit))
        return result.scalars().all()

    async def update(self, db_property: Property, property_in: PropertyUpdate) -> Property:
        """Update a property."""
        update_data = property_in.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(db_property, field, value)
        
        await self.db.commit()
        await self.db.refresh(db_property)
        return db_property

    async def delete(self, property_id: str) -> bool:
        """Delete a property."""
        db_property = await self.get_by_id(property_id)
        if not db_property:
            return False
        await self.db.delete(db_property)
        await self.db.commit()
        return True

    async def count(self, owner_id: Optional[str] = None) -> int:
        """Count properties."""
        query = select(func.count()).select_from(Property)
        if owner_id:
            query = query.where(Property.owner_id == owner_id)
        result = await self.db.execute(query)
        return result.scalar() or 0

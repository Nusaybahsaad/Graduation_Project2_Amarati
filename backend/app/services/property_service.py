"""
Property management service for Amarati.
"""

from typing import List, Optional
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.property import Property
from app.repositories.property_repository import PropertyRepository
from app.schemas.property import PropertyCreate, PropertyUpdate
from app.core.exceptions import NotFoundException


class PropertyService:
    """Service for property-related business logic."""

    def __init__(self, db: AsyncSession):
        self.repo = PropertyRepository(db)

    async def create_property(self, property_in: PropertyCreate) -> Property:
        """Create a new property."""
        return await self.repo.create(property_in)

    async def get_property(self, property_id: str) -> Property:
        """Get property by ID or raise 404."""
        db_property = await self.repo.get_by_id(property_id)
        if not db_property:
            raise NotFoundException(f"Property with ID {property_id} not found")
        return db_property

    async def list_properties(
        self, 
        skip: int = 0, 
        limit: int = 100,
        owner_id: Optional[str] = None,
        supervisor_id: Optional[str] = None,
        city: Optional[str] = None
    ) -> List[Property]:
        """List properties with pagination and filters."""
        return await self.repo.get_multi(
            skip=skip, limit=limit, owner_id=owner_id, 
            supervisor_id=supervisor_id, city=city
        )

    async def update_property(self, property_id: str, property_in: PropertyUpdate) -> Property:
        """Update property details."""
        db_property = await self.get_property(property_id)
        return await self.repo.update(db_property, property_in)

    async def delete_property(self, property_id: str) -> bool:
        """Delete a property."""
        # Ensure it exists
        await self.get_property(property_id)
        return await self.repo.delete(property_id)

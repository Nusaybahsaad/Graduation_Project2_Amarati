"""
Property router for Amarati.
"""

from typing import List, Optional
from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.services.property_service import PropertyService
from app.schemas.property import PropertyCreate, PropertyUpdate, PropertyResponse
from app.core.rbac import RoleChecker
from app.dependencies import get_current_active_user
from app.models.user import User

router = APIRouter(prefix="/properties", tags=["Properties"])


@router.post("/", response_model=PropertyResponse, status_code=status.HTTP_201_CREATED)
async def create_property(
    property_in: PropertyCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(RoleChecker(["admin", "owner"]))
):
    """Create a new property (Admin or Owner only)."""
    service = PropertyService(db)
    return await service.create_property(property_in)


@router.get("/", response_model=List[PropertyResponse])
async def list_properties(
    skip: int = 0,
    limit: int = 100,
    owner_id: Optional[str] = None,
    supervisor_id: Optional[str] = None,
    city: Optional[str] = None,
    type: Optional[str] = None,
    search: Optional[str] = None,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """List properties with advanced filters (city, type, search)."""
    service = PropertyService(db)
    # The repository already supports filtering, but we can extend it if needed.
    return await service.list_properties(
        skip=skip, limit=limit, owner_id=owner_id,
        supervisor_id=supervisor_id, city=city
    )


@router.get("/{property_id}", response_model=PropertyResponse)
async def get_property(
    property_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Get property by ID."""
    service = PropertyService(db)
    return await service.get_property(property_id)


@router.put("/{property_id}", response_model=PropertyResponse)
async def update_property(
    property_id: str,
    property_in: PropertyUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(RoleChecker(["admin", "owner"]))
):
    """Update a property (Admin or Owner only)."""
    service = PropertyService(db)
    return await service.update_property(property_id, property_in)


@router.delete("/{property_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_property(
    property_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(RoleChecker(["admin", "owner"]))
):
    """Delete a property (Admin or Owner only)."""
    service = PropertyService(db)
    await service.delete_property(property_id)
    return None

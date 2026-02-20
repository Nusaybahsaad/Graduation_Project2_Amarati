"""
Unit router for Amarati.
"""

from typing import List
from fastapi import APIRouter, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.services.unit_service import UnitService
from app.schemas.unit import UnitCreate, UnitUpdate, UnitResponse
from app.core.rbac import RoleChecker
from app.dependencies import get_current_active_user
from app.models.user import User

router = APIRouter(prefix="/units", tags=["Units"])


@router.post("/", response_model=UnitResponse, status_code=status.HTTP_201_CREATED)
async def create_unit(
    unit_in: UnitCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(RoleChecker(["admin", "owner"]))
):
    """Create a new unit (Admin or Owner only)."""
    service = UnitService(db)
    return await service.create_unit(unit_in)


@router.get("/property/{property_id}", response_model=List[UnitResponse])
async def list_units_by_property(
    property_id: str,
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """List units for a property."""
    service = UnitService(db)
    return await service.list_units_by_property(property_id, skip, limit)


@router.get("/{unit_id}", response_model=UnitResponse)
async def get_unit(
    unit_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Get unit by ID."""
    service = UnitService(db)
    return await service.get_unit(unit_id)


@router.put("/{unit_id}", response_model=UnitResponse)
async def update_unit(
    unit_id: str,
    unit_in: UnitUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(RoleChecker(["admin", "owner", "supervisor"]))
):
    """Update a unit (Admin, Owner, or Supervisor)."""
    service = UnitService(db)
    return await service.update_unit(unit_id, unit_in)


@router.delete("/{unit_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_unit(
    unit_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(RoleChecker(["admin", "owner"]))
):
    """Delete a unit (Admin or Owner only)."""
    service = UnitService(db)
    await service.delete_unit(unit_id)
    return None

"""
Unit schemas for Amarati.
"""

from typing import Optional
from decimal import Decimal
from pydantic import BaseModel, Field

from app.models.unit import UnitStatus


class UnitBase(BaseModel):
    unit_number: str = Field(..., min_length=1, max_length=50)
    floor: Optional[int] = None
    bedrooms: Optional[int] = None
    bathrooms: Optional[int] = None
    area_sqm: Optional[Decimal] = None
    rent_amount: Optional[Decimal] = None
    status: UnitStatus = UnitStatus.VACANT


class UnitCreate(UnitBase):
    property_id: str


class UnitUpdate(BaseModel):
    unit_number: Optional[str] = Field(None, min_length=1, max_length=50)
    floor: Optional[int] = None
    bedrooms: Optional[int] = None
    bathrooms: Optional[int] = None
    area_sqm: Optional[Decimal] = None
    rent_amount: Optional[Decimal] = None
    status: Optional[UnitStatus] = None
    tenant_id: Optional[str] = None


class UnitResponse(UnitBase):
    id: str
    property_id: str
    tenant_id: Optional[str]

    class Config:
        from_attributes = True

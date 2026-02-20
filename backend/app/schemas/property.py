"""
Property schemas for Amarati.
"""

from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field

from app.models.property import PropertyType


class PropertyBase(BaseModel):
    name: str = Field(..., min_length=2, max_length=255)
    address: str = Field(..., min_length=5)
    city: str = Field(..., min_length=2, max_length=100)
    type: PropertyType = PropertyType.RESIDENTIAL
    description: Optional[str] = None
    image_url: Optional[str] = None


class PropertyCreate(PropertyBase):
    owner_id: str
    supervisor_id: Optional[str] = None


class PropertyUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=2, max_length=255)
    address: Optional[str] = Field(None, min_length=5)
    city: Optional[str] = Field(None, min_length=2, max_length=100)
    type: Optional[PropertyType] = None
    description: Optional[str] = None
    image_url: Optional[str] = None
    supervisor_id: Optional[str] = None


class PropertyResponse(PropertyBase):
    id: str
    owner_id: str
    supervisor_id: Optional[str]
    total_units: int
    created_at: datetime

    class Config:
        from_attributes = True

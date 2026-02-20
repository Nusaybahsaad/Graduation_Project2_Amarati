"""
Unit model for Amarati.
"""

import uuid
from enum import Enum as PyEnum

from sqlalchemy import Column, Enum, ForeignKey, Integer, Numeric, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class UnitStatus(str, PyEnum):
    VACANT = "vacant"
    OCCUPIED = "occupied"
    MAINTENANCE = "maintenance"


class Unit(Base):
    """Unit model representing a single apartment, office, etc."""

    __tablename__ = "units"

    id: Mapped[str] = mapped_column(
        String(36),
        primary_key=True,
        default=lambda: str(uuid.uuid4()),
    )
    property_id: Mapped[str] = mapped_column(
        String(36),
        ForeignKey("properties.id", ondelete="CASCADE"),
        nullable=False,
    )
    unit_number: Mapped[str] = mapped_column(String(50), nullable=False)
    floor: Mapped[int | None] = mapped_column(Integer, nullable=True)
    bedrooms: Mapped[int | None] = mapped_column(Integer, nullable=True)
    bathrooms: Mapped[int | None] = mapped_column(Integer, nullable=True)
    area_sqm: Mapped[float | None] = mapped_column(Numeric(10, 2), nullable=True)
    rent_amount: Mapped[float | None] = mapped_column(Numeric(10, 2), nullable=True)
    
    status: Mapped[UnitStatus] = mapped_column(
        Enum(UnitStatus),
        nullable=False,
        default=UnitStatus.VACANT,
    )
    
    tenant_id: Mapped[str | None] = mapped_column(
        String(36),
        ForeignKey("users.id", ondelete="SET NULL"),
        nullable=True,
    )

    # Relationships
    property = relationship("Property", back_populates="units")

    def __repr__(self) -> str:
        return f"<Unit {self.unit_number} in Property {self.property_id}>"

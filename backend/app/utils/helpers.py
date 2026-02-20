"""
Utility helper functions.
"""

import re
from typing import Optional


def is_valid_email(email: str) -> bool:
    """Basic email format validation."""
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return re.match(pattern, email) is not None


def is_valid_phone(phone: str) -> bool:
    """Basic phone number validation (international format)."""
    pattern = r'^\+?[1-9]\d{6,14}$'
    return re.match(pattern, phone) is not None


def sanitize_string(value: Optional[str]) -> Optional[str]:
    """Strip and clean input strings."""
    if value is None:
        return None
    return value.strip()

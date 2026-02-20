"""
Test configuration and fixtures.
"""

import os
os.environ["DEBUG"] = "True"

import asyncio
import uuid
from typing import AsyncGenerator

import pytest
import pytest_asyncio
from httpx import ASGITransport, AsyncClient
from sqlalchemy import select

from app.database import Base, engine, async_session_factory
from app.main import app
from app.config import get_settings
from app.models.user import User
from app.models.otp import OTPCode

settings = get_settings()
settings.DEBUG = True


@pytest.fixture(scope="session")
def event_loop():
    """Create an event loop for the test session."""
    loop = asyncio.new_event_loop()
    yield loop
    loop.close()


@pytest_asyncio.fixture(autouse=True)
async def setup_database():
    """Create tables before each test, drop after."""
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)


@pytest_asyncio.fixture
async def client() -> AsyncGenerator[AsyncClient, None]:
    """Async HTTP test client."""
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        yield ac


@pytest_asyncio.fixture
async def db_session():
    """Provide a database session for tests."""
    async with async_session_factory() as session:
        yield session


@pytest_asyncio.fixture
async def token_headers(client: AsyncClient) -> dict:
    """Register and verify a test user, then return auth headers."""
    unique_id = str(uuid.uuid4())[:8]
    user_data = {
        "email": f"tester_{unique_id}@amarati.com",
        "password": "Password123!",
        "full_name": "Test User",
        "phone": f"+1234567{unique_id}",
        "role": "owner",
    }
    # 1. Register
    reg = await client.post("/api/v1/auth/register", json=user_data)
    assert reg.status_code == 201
    
    # 2. Fetch OTP from DB (generated during registration)
    async with async_session_factory() as session:
        result = await session.execute(
            select(OTPCode.code)
            .join(User)
            .where(User.email == user_data["email"])
            .order_by(OTPCode.created_at.desc())
        )
        otp_code = result.scalar()
    
    # 3. Verify
    verify = await client.post("/api/v1/auth/verify-otp", json={"email": user_data["email"], "code": otp_code})
    assert verify.status_code == 200
        
    # 4. Login
    login = await client.post("/api/v1/auth/login", json={"email": user_data["email"], "password": user_data["password"]})
    assert login.status_code == 200
    token = login.json()["access_token"]
    
    return {"Authorization": f"Bearer {token}"}

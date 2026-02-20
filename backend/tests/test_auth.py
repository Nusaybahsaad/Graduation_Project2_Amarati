"""
Authentication endpoint tests.
"""

import pytest
from httpx import AsyncClient


# ── Test Data ──────────────────────────────────────────────────
TEST_USER = {
    "email": "test@amarati.com",
    "password": "Test123456!",
    "full_name": "Test User",
    "phone": "+1234567890",
    "role": "owner",
}


@pytest.mark.asyncio
async def test_register_success(client: AsyncClient):
    """Test successful user registration."""
    response = await client.post("/api/v1/auth/register", json=TEST_USER)
    assert response.status_code == 201
    data = response.json()
    assert data["email"] == TEST_USER["email"]
    assert data["full_name"] == TEST_USER["full_name"]
    assert data["role"] == TEST_USER["role"]
    assert data["is_verified"] is False


@pytest.mark.asyncio
async def test_register_duplicate_email(client: AsyncClient):
    """Test registration with duplicate email fails."""
    await client.post("/api/v1/auth/register", json=TEST_USER)
    response = await client.post("/api/v1/auth/register", json=TEST_USER)
    assert response.status_code == 409


@pytest.mark.asyncio
async def test_login_unverified_user(client: AsyncClient):
    """Test login with unverified account fails."""
    await client.post("/api/v1/auth/register", json=TEST_USER)
    response = await client.post(
        "/api/v1/auth/login",
        json={"email": TEST_USER["email"], "password": TEST_USER["password"]},
    )
    assert response.status_code == 400
    assert "not verified" in response.json()["detail"].lower()


@pytest.mark.asyncio
async def test_login_wrong_password(client: AsyncClient):
    """Test login with wrong password fails."""
    await client.post("/api/v1/auth/register", json=TEST_USER)
    response = await client.post(
        "/api/v1/auth/login",
        json={"email": TEST_USER["email"], "password": "wrongpassword"},
    )
    assert response.status_code == 401


@pytest.mark.asyncio
async def test_full_auth_flow(client: AsyncClient):
    """Test complete: register → resend OTP → verify → login → me → refresh → logout."""
    # 1. Register
    reg_response = await client.post("/api/v1/auth/register", json=TEST_USER)
    assert reg_response.status_code == 201

    # 2. Resend OTP (get code in debug mode)
    resend_response = await client.post(
        "/api/v1/auth/resend-otp",
        json={"email": TEST_USER["email"]},
    )
    assert resend_response.status_code == 200
    otp_code = resend_response.json().get("otp_code")
    assert otp_code is not None  # Debug mode returns OTP

    # 3. Verify OTP
    verify_response = await client.post(
        "/api/v1/auth/verify-otp",
        json={"email": TEST_USER["email"], "code": otp_code},
    )
    assert verify_response.status_code == 200
    tokens = verify_response.json()
    assert "access_token" in tokens
    assert "refresh_token" in tokens

    # 4. Login
    login_response = await client.post(
        "/api/v1/auth/login",
        json={"email": TEST_USER["email"], "password": TEST_USER["password"]},
    )
    assert login_response.status_code == 200
    login_tokens = login_response.json()
    access_token = login_tokens["access_token"]
    refresh_token = login_tokens["refresh_token"]

    # 5. Get current user (/me)
    me_response = await client.get(
        "/api/v1/auth/me",
        headers={"Authorization": f"Bearer {access_token}"},
    )
    assert me_response.status_code == 200
    me_data = me_response.json()
    assert me_data["email"] == TEST_USER["email"]
    assert me_data["is_verified"] is True

    # 6. Refresh token
    refresh_response = await client.post(
        "/api/v1/auth/refresh",
        json={"refresh_token": refresh_token},
    )
    assert refresh_response.status_code == 200
    assert "access_token" in refresh_response.json()

    # 7. Logout
    logout_response = await client.post(
        "/api/v1/auth/logout",
        headers={"Authorization": f"Bearer {access_token}"},
    )
    assert logout_response.status_code == 200


@pytest.mark.asyncio
async def test_password_reset_flow(client: AsyncClient):
    """Test password reset: request OTP → confirm → login with new password."""
    # Register and verify
    await client.post("/api/v1/auth/register", json=TEST_USER)
    resend = await client.post(
        "/api/v1/auth/resend-otp", json={"email": TEST_USER["email"]}
    )
    otp = resend.json()["otp_code"]
    await client.post(
        "/api/v1/auth/verify-otp",
        json={"email": TEST_USER["email"], "code": otp},
    )

    # Request password reset
    reset_req = await client.post(
        "/api/v1/auth/request-password-reset",
        json={"email": TEST_USER["email"]},
    )
    assert reset_req.status_code == 200
    reset_otp = reset_req.json()["otp_code"]

    # Confirm password reset
    new_password = "NewPassword123!"
    confirm = await client.post(
        "/api/v1/auth/confirm-password-reset",
        json={
            "email": TEST_USER["email"],
            "code": reset_otp,
            "new_password": new_password,
        },
    )
    assert confirm.status_code == 200

    # Login with new password
    login = await client.post(
        "/api/v1/auth/login",
        json={"email": TEST_USER["email"], "password": new_password},
    )
    assert login.status_code == 200


@pytest.mark.asyncio
async def test_protected_endpoint_no_token(client: AsyncClient):
    """Test protected endpoint without token returns 401."""
    response = await client.get("/api/v1/auth/me")
    assert response.status_code == 401


@pytest.mark.asyncio
async def test_health_check(client: AsyncClient):
    """Test health check endpoint."""
    response = await client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"

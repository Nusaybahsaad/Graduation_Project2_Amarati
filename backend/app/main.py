"""
Amarati Property Management System — FastAPI Application Entry Point.

This is the main application file that:
- Creates the FastAPI app instance
- Configures CORS middleware
- Registers authentication middleware
- Mounts API v1 routers
- Provides health check endpoint
- Handles startup/shutdown events
"""

from contextlib import asynccontextmanager

from fastapi import FastAPI, APIRouter
from fastapi.middleware.cors import CORSMiddleware

from app.config import get_settings
from app.database import create_tables
from app.middleware.auth_middleware import AuthMiddleware
from app.routers import auth, users, properties, units

settings = get_settings()


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan: startup and shutdown events."""
    # Startup: create tables (dev only — use Alembic in production)
    if settings.DEBUG:
        await create_tables()
        print(f"[START] {settings.APP_NAME} v{settings.APP_VERSION} started (DEBUG mode)")
        print(f"[DB] Database: {settings.DATABASE_URL}")
    yield
    # Shutdown
    print(f"[STOP] {settings.APP_NAME} shutting down")


# ── App instance ─────────────────────────────────────────────────
app = FastAPI(
    title=settings.APP_NAME,
    description=(
        "Multi-role property management system API. "
        "Supports Owner, Tenant, Supervisor, Service Provider, and Admin roles."
    ),
    version=settings.APP_VERSION,
    lifespan=lifespan,
    docs_url="/docs",
    redoc_url="/redoc",
)

# ── CORS ─────────────────────────────────────────────────────────
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── Auth Middleware ──────────────────────────────────────────────
app.add_middleware(AuthMiddleware)

# ── API Routes ───────────────────────────────────────────────────
from app.routers import auth, users, properties, units

api_router = APIRouter(prefix=settings.API_V1_STR)
api_router.include_router(auth.router)
api_router.include_router(users.router)
api_router.include_router(properties.router)
api_router.include_router(units.router)

app.include_router(api_router)


# ── Health Check ─────────────────────────────────────────────────
@app.get("/", tags=["Root"])
async def root():
    """Root endpoint."""
    return {
        "app": settings.APP_NAME,
        "version": settings.APP_VERSION,
        "docs": "/docs",
    }


@app.get("/health", tags=["Health"])
async def health_check():
    """Health check endpoint."""
    return {"status": "ok", "app": settings.APP_NAME}

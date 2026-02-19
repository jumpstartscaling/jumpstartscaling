"""God Mode API configuration. All secrets via environment variables."""
import os
from urllib.parse import urlparse


def _get_db_url() -> str:
    url = os.getenv("DATABASE_URL")
    if url:
        return url
    host = os.getenv("DB_HOST", "localhost")
    name = os.getenv("DB_NAME", "god_mode")
    user = os.getenv("DB_USER", "god_user")
    password = os.getenv("DB_PASSWORD", "")
    port = os.getenv("DB_PORT", "5432")
    return f"postgresql://{user}:{password}@{host}:{port}/{name}"


class Config:
    """Application configuration."""
    # Server
    HOST: str = os.getenv("HOST", "0.0.0.0")
    PORT: int = int(os.getenv("PORT", "8200"))

    # Database
    DATABASE_URL: str = _get_db_url()

    # Admin (for /admin/leads style access)
    ADMIN_KEY: str = os.getenv("ADMIN_KEY", "spark")

    # Optional: disable request logging to DB (reduces crashes when DATABASE_URL missing)
    LOG_REQUESTS: bool = os.getenv("LOG_REQUESTS", "false").lower() in ("1", "true", "yes")


config = Config()

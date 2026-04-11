from __future__ import annotations

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Runtime configuration; override via environment variables."""

    model_config = SettingsConfigDict(env_prefix="AXIMATE_ORCH_", extra="ignore")

    host: str = "0.0.0.0"
    port: int = 8080
    log_level: str = "INFO"
    api_key: str | None = Field(
        default=None,
        description="If set, require matching X-API-Key header on all requests.",
    )


def load_settings() -> Settings:
    return Settings()

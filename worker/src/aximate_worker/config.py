from __future__ import annotations

from pydantic_settings import BaseSettings, SettingsConfigDict


class WorkerSettings(BaseSettings):
    model_config = SettingsConfigDict(env_prefix="AXIMATE_WORKER_", extra="ignore")

    host: str = "0.0.0.0"
    port: int = 8090
    log_level: str = "INFO"


def load_worker_settings() -> WorkerSettings:
    return WorkerSettings()

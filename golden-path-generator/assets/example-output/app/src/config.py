"""Application configuration loaded from environment variables."""

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Service configuration with environment variable binding."""

    service_name: str = "payment-service"
    version: str = "0.1.0"
    environment: str = "development"
    log_level: str = "INFO"
    port: int = 8080

    # Database
    database_url: str = "postgresql://localhost:5432/payments"
    db_pool_size: int = 10
    db_pool_timeout: int = 30

    # AWS
    aws_region: str = "us-east-1"

    class Config:
        env_prefix = ""
        case_sensitive = False


settings = Settings()

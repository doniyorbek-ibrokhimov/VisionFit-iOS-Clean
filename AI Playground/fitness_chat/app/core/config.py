from pydantic_settings import BaseSettings
from pydantic import PostgresDsn
from typing import Optional
from functools import lru_cache


class Settings(BaseSettings):
    PROJECT_NAME: str = "CEO Chat"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    
    # Database
    DATABASE_URL: PostgresDsn
    
    # OpenAI
    OPENAI_API_KEY: str
    ASSISTANT_ID: Optional[str] = None
    
    # Security
    SECRET_KEY: str = "your-secret-key-here"  # Change in production
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 8  # 8 days

    # Groq
    GROQ_API_KEY: str

    # Eduplus
    EDUPLUS_TOKEN: str
    EDUPLUS_URL: str
    
    class Config:
        env_file = ".env"
        case_sensitive = True
        extra='ignore'
        


@lru_cache()
def get_settings() -> Settings:
    return Settings()

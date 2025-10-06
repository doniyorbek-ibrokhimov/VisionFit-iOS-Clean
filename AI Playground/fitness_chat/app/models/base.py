from datetime import datetime
from sqlalchemy import func, TIMESTAMP, String
from sqlalchemy.orm import Mapped, mapped_column, DeclarativeBase
from sqlalchemy.ext.asyncio import AsyncAttrs, async_sessionmaker, create_async_engine, AsyncSession
from uuid import uuid4

from app.core.config import get_settings

settings = get_settings()

# Create async engine
engine = create_async_engine(
    settings.DATABASE_URL.unicode_string(),
    future=True,
)


session_maker = async_sessionmaker(engine, class_=AsyncSession)

class Base(AsyncAttrs, DeclarativeBase):
    __abstract__ = True  # Этот класс не будет создавать отдельную таблицу

    id: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: str(uuid4()))

    # Поля времени создания и обновления записи
    created_at: Mapped[datetime] = mapped_column(
        TIMESTAMP, server_default=func.now()
    )
    updated_at: Mapped[datetime] = mapped_column(
        TIMESTAMP, server_default=func.now(), onupdate=func.now()
    )

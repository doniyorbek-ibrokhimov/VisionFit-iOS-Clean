from sqlalchemy.ext.asyncio import AsyncSession
from app.models.base import Base, engine


async def init_db():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)


async def get_db() -> AsyncSession:
    async with AsyncSession(engine) as session:
        yield session

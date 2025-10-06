import logging
from contextlib import asynccontextmanager

import uvicorn
from fastapi import FastAPI, Request, Response
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware

from app.api import api_router
from app.core.config import get_settings
from app.db.init_db import engine, init_db

settings = get_settings()

@asynccontextmanager
async def lifespan(app: FastAPI):
    logging.info("Starting up...")
    await init_db()
    logging.info("Database initialized")
    await engine.connect()
    logging.info("Database connection established")
    yield
    logging.info("Shutting down...")
    await engine.dispose()




app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION
)

# Set up CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Modify in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include API router
app.include_router(api_router, prefix=settings.API_V1_STR, tags=['AI_chat'])

async def custom_500_handler(request: Request, exc: Exception) -> Response:
    return JSONResponse(status_code=500, content={"detail": "Internal Server Error",
                                                 "message": str(exc)})


# Set up exception handlers
app.add_exception_handler(500, custom_500_handler)


@app.get("/health")
async def health_check():
    return {"status": "healthy"}


if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True
    )

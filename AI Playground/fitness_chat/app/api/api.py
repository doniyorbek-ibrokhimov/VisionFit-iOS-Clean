import logging
import sys
from typing import List, Optional

from agents import Runner, trace

from fastapi import APIRouter, Depends, HTTPException
from openai import AsyncOpenAI
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import get_settings
from app.db.init_db import get_db
from app.models.models import Message
from app.models.models import Session as SessionModel

from app.schemas.schemas import ChatRequest, ChatResponse, ChatStatus
from app.schemas.schemas import Session, SessionCreate
from app.agents.eduplus_agent import cau_comprehensive_agent

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(filename)s:%(lineno)d - %(levelname)s - %(message)s",
    handlers=[logging.StreamHandler(sys.stdout)],
)


logger = logging.getLogger(__name__)

settings = get_settings()
client = AsyncOpenAI(api_key=settings.OPENAI_API_KEY, timeout=200)

router = APIRouter()



@router.get("/sessions", response_model=List[Session])
async def get_sessions(
    user_id: Optional[str] = None,
    db: AsyncSession = Depends(get_db),
):
    query = select(SessionModel)
    if user_id:
        query = query.filter(SessionModel.user_id == user_id)
    result = await db.execute(query)
    sessions = result.scalars().all()
    return sessions


@router.post("/sessions", response_model=Session)
async def create_session(session: SessionCreate, db: AsyncSession = Depends(get_db)):
    db_session = SessionModel(
        title=session.title,
        user_id=session.user_id,
    )
    db.add(db_session)
    await db.commit()
    await db.refresh(db_session)
    return db_session



@router.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest, db: AsyncSession = Depends(get_db)):
    # Explicitly select all needed attributes to avoid lazy loading issues
    session = await db.execute(
        select(SessionModel)
        .filter(SessionModel.id == request.session_id)
        .order_by(SessionModel.id.desc())
    )
    session = session.scalar_one_or_none()  # type: ignore
    if not session:
        raise HTTPException(
            status_code=404, detail=f"Session {request.session_id} not found"
        )
    
    # Store the session ID in a variable to avoid lazy loading issues later
    
    context = [
        {
            "role": message.role,
            "content": message.content
        } for message in session.messages
    ]


    session_id = session.id
    db_message = Message(
        session_id=session_id,
        role="user",
        content=request.message,
    )
    db.add(db_message)
    await db.commit()
    
    # Run the agent outside of any database transaction
    runner = Runner()
    with trace(workflow_name="cau_comprehensive_agent", group_id=request.session_id):
        res = await runner.run(cau_comprehensive_agent, input=context+ [{"role": "user", "content": request.message}])

    # Create and save the assistant's message
    ast_message = Message(
        session_id=session_id,
        role="assistant",
        content=res.final_output,
    )
    db.add(ast_message)
    await db.commit()

    return ChatResponse(
        session_id=session_id,
        message=request.message,
        assistant_response=res.final_output,
        status=ChatStatus.completed,
    )


# @router.get("/chat/{session_id}/{run_id}", response_model=ChatResponse)
# async def get_chat_response(
#     session_id: str, run_id: str, limit: int = 100, db: AsyncSession = Depends(get_db)
# ):
#     result = await db.execute(select(Session).filter(Session.id == session_id))
#     session = result.scalar_one_or_none()
#     if not session:
#         raise HTTPException(status_code=404, detail=f"Session {session_id} not found")

#     result = await db.execute(
#         select(Message)
#         .filter(Message.session_id == session.id)
#         .filter(Message.run_id == run_id)
#         .order_by(Message.created_at)
#     )
#     messages = result.scalars().all()
#     logger.info(f"Messages: {messages}")
#     if len(messages) == 2:
#         user_message = messages[0].content
#         assistant_response = messages[1].content
#         return ChatResponse(
#             session_id=session_id,
#             message=user_message,
#             assistant_response=assistant_response,
#             status="completed",
#         )
#     else:
#         return ChatResponse(
#             session_id=session_id,
#             message="",
#             assistant_response="",
#             status="in_progress",
#         )


@router.get("/ask")
async def ask_question(question: str, db: AsyncSession = Depends(get_db)):
    runner = Runner()
    res = await runner.run(cau_comprehensive_agent, input=question)

    return {"message": res.final_output}

    
    

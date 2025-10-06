from pydantic import BaseModel
from typing import Optional, List, Dict, Any
from datetime import datetime
from enum import Enum


class MessageBase(BaseModel):
    role: str
    content: str


class MessageCreate(MessageBase):
    pass


class Message(MessageBase):
    id: str
    created_at: datetime

    class Config:
        from_attributes = True


class SessionBase(BaseModel):
    title: str


class SessionCreate(SessionBase):
    title: str = ""
    user_id: str



class Session(SessionBase):
    id: str
    user_id: str
    created_at: datetime
    updated_at: datetime
    messages: List[Message] = []

    class Config:
        from_attributes = True





class ChatRequest(BaseModel):
    session_id: str
    message: str
    img_url: Optional[str] = None


class ChatRunResponse(BaseModel):
    run_id: str



class ChatStatus(Enum):
    completed = "completed"
    failed = "failed"
    cancelled = "cancelled"
    in_progress = "in_progress"
    queued = "queued"


class ChatResponse(BaseModel):
    session_id: str
    """
    Session ID that will come from openai API
    """
    message: Optional[str] = None
    assistant_response: Optional[str] = None
    """
    Model's answer
    """
    status: ChatStatus = ChatStatus.completed
    """
    status: ChatStatus

    """



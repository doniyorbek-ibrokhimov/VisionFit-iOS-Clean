from sqlalchemy import Column, String, Text, ForeignKey, JSON
from sqlalchemy.orm import relationship
from .base import Base
from uuid import uuid4

class Session(Base):
    __tablename__ = "sessions"
    title = Column(String)
    user_id = Column(String)
    messages = relationship("Message", back_populates="session", cascade="all, delete-orphan", lazy="selectin", order_by="Message.created_at")

    def __repr__(self):
        return f"Session(id={self.id}, title={self.title}, created_at={self.created_at})"


class Message(Base):
    __tablename__ = "messages"
    session_id = Column(String, ForeignKey("sessions.id"))
    role = Column(String)  # user or assistant
    content = Column(Text)
    file_id = Column(String, nullable=True)
    run_id = Column(String, nullable=True)
    message_metadata = Column(JSON, default=dict)  # json

    session = relationship("Session", back_populates="messages", lazy="selectin")

    def __repr__(self):
        return f"Message(id={self.id}, session_id={self.session_id}, role={self.role}, created_at={self.created_at})"

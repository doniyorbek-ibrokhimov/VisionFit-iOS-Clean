from sqladmin import ModelView
from app.models.models import Thread, Message, Note, Flashcard


class ThreadAdmin(ModelView, model=Thread):
    name = "Thread"
    name_plural = "Threads"
    icon = "fa-solid fa-comments"
    column_list = [c for c in Thread.__table__.columns.keys()]
    column_searchable_list = [Thread.title, Thread.student_id]
    column_sortable_list = [Thread.id, Thread.created_at]
    can_create = True
    can_edit = True
    can_delete = True
    can_view_details = True


class MessageAdmin(ModelView, model=Message):
    name = "Message"
    name_plural = "Messages"
    icon = "fa-solid fa-envelope"
    column_list = [c for c in Message.__table__.columns.keys()]
    column_searchable_list = [Message.content]
    column_sortable_list = [Message.id, Message.created_at]
    can_create = True
    can_edit = True
    can_delete = True
    can_view_details = True


class NoteAdmin(ModelView, model=Note):
    name = "Note"
    name_plural = "Notes"
    icon = "fa-solid fa-sticky-note"
    column_list = [c for c in Note.__table__.columns.keys()]
    column_searchable_list = [Note.title, Note.content]
    column_sortable_list = [Note.id, Note.created_at]
    can_create = True
    can_edit = True
    can_delete = True
    can_view_details = True


class FlashcardAdmin(ModelView, model=Flashcard):
    name = "Flashcard"
    name_plural = "Flashcards"
    icon = "fa-solid fa-cards-blank"
    column_list = [c for c in Flashcard.__table__.columns.keys()]
    column_searchable_list = [Flashcard.question, Flashcard.answer]
    column_sortable_list = [Flashcard.id, Flashcard.created_at]
    can_create = True
    can_edit = True
    can_delete = True
    can_view_details = True

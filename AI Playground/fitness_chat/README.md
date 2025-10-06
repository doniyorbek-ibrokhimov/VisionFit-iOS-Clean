# OpenAI chatgpt assistant wrapper for AI teacher

we'll use the OpenAI assistant to answer questions as an AI teacher
this is FastAPI app with endpoints for the OpenAI API

## Endpoints
- `threads` - GET - get all threads
- `threads/{id}` - GET - get a thread
- `threads/{id}` - DELETE - delete a thread
- `/chat` - POST - ask a question to the OpenAI assistant


we have to save the threads, messages and notes to the database, 
create models for them, use pydantic to validate the data, sqlalchemy to create the database, alembic to manage the database, 
and use fastapi to create the API, use fully async code, use uvicorn to run the app
i need simply dashboard to show the threads, messages and notes use fastapi-admin to create the dashboard

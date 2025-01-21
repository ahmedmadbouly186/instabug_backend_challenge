# Chat System: Design and Implementation

## Quick Start

To run the entire stack, simply use:

```bash
docker-compose up --build
```
if the bash closed with error 'service X is unhelathy' so please run the command docker-compose up again ,its happens sometimes because the dependencies 
## System Overview

This application is a chat system designed to efficiently manage chats and messages for multiple applications. The system uses a Rails server with Sidekiq for background job processing, Redis for atomic operations and concurrency control, and Elasticsearch for advanced search capabilities.

---

## System Design

### Backend Architecture

the main part of the system founded in app/modes , app/controllers , config/initializers

the background workers founded in app/sidekiq

- **Rails Server**: Handles API requests and coordinates operations.
- **Sidekiq**: Manages background jobs, such as creating chats and messages, and updating counters asynchronously.
- **Redis**:
  - Used to store atomic counters for generating unique `chat_number` (per app) and `message_number` (per chat).
  - Ensures concurrency control during simultaneous requests.
- **Elasticsearch**: Provides support for partial and proximity search for messages.

---

### Workflow

1. **Unique Identifiers**:
   - Upon initialization, the system preloads the number of existing chats per app and messages per chat from the database.
   - Redis atomic operations generate unique `chat_number` and `message_number` to avoid race conditions.
2. **Chat Creation**:
   - **Step 1**: The main server uses Redis to create a unique `chat_number` and atomically increment it. It then returns the `chat_number` to the client and pushes the creation request into the message queue.
   - **Step 2**: The background job receives the creation request, creates the chat entity in the database, and increments the `chat_number` in the database.
3. **Message Creation**:
   - Users specify the chat via app token and `chat_number`.
   - A unique `message_number` is generated and stored in Redis.
   - The system increments the message counter for the chat asynchronously.
4. **Partial Search**:
   - Elasticsearch is used to find messages that closely match the user query within a specific chat.

---

## Database Design

### Entities and Relationships

![plot](./images/1.png)

you could see all of it in ./db/migrate

1. **App**: Represents an application with chats and messages.
   - `id` (Primary Key)
   - `token` (Unique, indexed for fast search)
   - `name`
   - `chat_count` (Default: 0)
2. **Chat**: Represents a conversation linked to an app.
   - `id` (Primary Key)
   - `app_id` (Foreign Key, indexed for search)
   - `chat_number` (Unique per app, indexed)
   - `messages_count` (Default: 0)
3. **Message**: Represents messages in a chat.
   - `id` (Primary Key)
   - `chat_id` (Foreign Key, indexed for search)
   - `message_number` (Unique per chat, indexed)
   - `body`

### Indexes

- **Apps Table**:
  - `token`: Optimizes lookup by app token.
- **Chats Table**:
  - Composite index on `[app_id, chat_number]`: Ensures uniqueness and speeds up searches.
  - `app_id`: Optimizes searches by app.
- **Messages Table**:
  - Composite index on `[chat_id, message_number]`: Ensures message uniqueness within a chat.
  - `chat_id`: Optimizes retrieval of messages by chat.

## API Endpoints

you could find add endpoints in file ./config/routes.rb

### Applications

- **POST /applications/**: Create a new application,default chat_count=0.
- **GET /applications/:token**: Retrieve application details (name, chat count).
- **PUT /applications/:token**: Update the application name.

### Chats

- **POST /apps/:app_token/chats**: Create a new chat under a specific app, default message_count=0.
- **GET /chats**: Retrieve all chats across the system.
- **GET /applications/:token/chats**: Retrieve all chats for a specific app.

### Messages

- **POST /apps/:app_token/chats/:chat_number/messages**: Create a new message in a chat.
- **GET /messages**: Retrieve all messages across the system.
- **GET /apps/:app_token/chats/:chat_number/messages?query="text"**: Perform a partial search within a chat using Elasticsearch ,if the user dont pass the query then the response will Retrieve all messages in a specific chat.

---

## Redis Implementation

Redis ensures atomic operations to generate unique numbers:

1. **Initialization**:
   - Load chat and message counts into Redis on startup.
2. **Concurrency Control**:
   - Increment chat and message counters atomically.
   - Prevent race conditions during simultaneous requests.

---

## Elasticsearch Integration

- **Search Capabilities**:
  - Partial and proximity search for messages.
  - Query-based filtering at the chat.

---

## Setup and Deployment

1. **Database**:
   - Use MySQL (Docker setup provided).
   - Set up necessary indexes for optimization.
2. **Redis**:
   - Build and run the Redis container.
3. **Sidekiq**:
   - Configure for background job processing.
4. **Elasticsearch**:
   - Ensure Elasticsearch is running for search endpoints.

---

## Future Enhancements

- add cashing for all data requested to return direct when asked again
- Enhanced analytics and reporting.
- API rate-limiting for better control.

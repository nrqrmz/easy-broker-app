# EasyBroker Property Agent

A RAG (Retrieval-Augmented Generation) application for intelligent property search using natural language processing. This application enables users to find properties through conversational AI, powered by semantic search and real-time streaming responses.

## Live Demo

👉 [https://easy-broker-rag-20ce900b246d.herokuapp.com/](https://easy-broker-rag-20ce900b246d.herokuapp.com/)

## Screenshots

<p align="center">
  <img src="https://res.cloudinary.com/druc0epi3/image/upload/v1766088042/WhatsApp_Image_2025-12-18_at_13.57.28_1_vykdwd.jpg" width="180" alt="App sign up"/>
  <img src="https://res.cloudinary.com/druc0epi3/image/upload/v1766088043/WhatsApp_Image_2025-12-18_at_13.57.28_3_nlirty.jpg" width="180" alt="Location Detection"/>
  <img src="https://res.cloudinary.com/druc0epi3/image/upload/v1766088043/WhatsApp_Image_2025-12-18_at_13.57.29_ii4quw.jpg" width="180" alt="Chat interface"/>
  <img src="https://res.cloudinary.com/druc0epi3/image/upload/v1766088042/WhatsApp_Image_2025-12-18_at_13.57.28_2_txbiix.jpg" width="180" alt="Property details 1"/>
  <img src="https://res.cloudinary.com/druc0epi3/image/upload/v1766088042/WhatsApp_Image_2025-12-18_at_13.57.28_kxycgb.jpg" width="180" alt="Property details 2"/>
</p>

## Features

- **Semantic Property Search**: Query properties using natural language instead of traditional filters
- **Real-time AI Responses**: LLM responses streamed live using Solid Cable and Turbo Streams
- **Agentic Behavior**: AI agent determines when to use tools based on conversation context
- **Location Detection**: Automatic user location detection to provide contextually relevant results
- **Vector Embeddings**: 1,197 properties indexed with embeddings for semantic similarity search

## Tech Stack

- **Ruby on Rails** with Hotwire (Turbo Streams)
- **PostgreSQL** with pgvector extension
- **Solid Queue** for background job processing
- **Solid Cable** for real-time WebSocket communication
- **Neighbor gem** for vector similarity search
- **Ruby LLM** for AI chat and tool integration
- **EasyBroker gem** for property data synchronization

## Setup

### Prerequisites

- Ruby 3.x
- PostgreSQL with pgvector extension

### Installation
```bash
bundle install
rails db:create db:migrate
```

### Environment Variables
```bash
EASYBROKER_API_KEY=your_api_key
OPENAI_API_KEY=your_openai_key
```

## Data Pipeline

### 1. Sync Properties

Fetch all properties from the EasyBroker API and store them in the database:
```bash
rails properties:sync_properties
```

### 2. Enrich Properties

Generate embeddings for all properties using background jobs powered by Solid Queue:
```bash
rails properties:enrich_properties
```

This task processes properties asynchronously, generating vector embeddings that enable semantic search capabilities.

## Architecture

### RAG Pipeline

1. **User Query** → Natural language input from the user
2. **Embedding Generation** → Query converted to vector embedding
3. **Semantic Search** → Neighbor gem finds similar properties using pgvector
4. **Context Augmentation** → Relevant properties added to LLM context
5. **Response Generation** → LLM generates contextual response
6. **Real-time Streaming** → Response streamed via Solid Cable + Turbo Streams

### Agentic Tool System

The application uses Ruby LLM tools to implement agentic behavior. The AI agent autonomously decides when to invoke tools based on the conversation context:

- **Location Tool**: Detects user location from the request to provide geographically relevant property suggestions

## Real-time Communication

Responses are streamed in real-time using:

- **Solid Cable**: PostgreSQL-backed Action Cable adapter
- **Turbo Streams**: Live DOM updates as the LLM generates responses

## License

MIT

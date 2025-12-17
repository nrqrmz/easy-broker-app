# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**EasyBroker Property Agent** is a conversational AI agent that enables natural language property search using EasyBroker's real estate database. Users can ask questions like "Busco departamento en Condesa, 2 recámaras, máximo 25k de renta" and receive intelligent, contextual responses with matching properties.

## Commands

### Development
```bash
bin/rails server              # Start development server
bin/rails console             # Rails console
```

### Database
```bash
bin/rails db:create           # Create database
bin/rails db:migrate          # Run migrations
bin/rails db:seed             # Seed database
bin/rails db:reset            # Drop, create, migrate, seed
```

### EasyBroker
```bash
bin/rails easy_broker:sync_properties    # Sync properties from EasyBroker staging API
bin/rails easy_broker:enrich_properties  # Enqueue jobs to fetch full property details (run after sync)
```

### Testing
```bash
bin/rails test                          # Run all tests
bin/rails test test/models              # Run model tests
bin/rails test test/models/user_test.rb # Run single test file
bin/rails test test/models/user_test.rb:10  # Run test at specific line
bin/rails test:system                   # Run system tests
```

### Code Quality
```bash
rubocop                       # Run linter
rubocop -a                    # Auto-fix offenses
```

### Background Jobs
```bash
bin/rails solid_queue:start   # Start Solid Queue worker
```

## Architecture

This is a Rails 7.1 application using the Le Wagon template with Devise authentication.

### Tech Stack
- **Ruby 3.3.5 / Rails 7.1** with PostgreSQL
- **Frontend**: Hotwire (Turbo + Stimulus), importmap-rails (no Node.js/webpack)
- **Styling**: Bootstrap 5.3 with SCSS (all styles in `app/assets/stylesheets/`)
- **Forms**: SimpleForm with Bootstrap integration
- **Auth**: Devise
- **Background Jobs**: Solid Queue
- **Caching**: Solid Cache
- **WebSockets**: Solid Cable
- **AI**: ruby_llm gem
- **Real Estate Data**: easy_broker gem (EasyBroker staging API)

### Key Models
- `User` - Devise authentication
- `Property` - Real estate listings with location, pricing, and features (JSONB)

### Key Services
- `EasyBrokerSyncService` - Bulk sync properties from API listing endpoint
- `EnrichPropertyJob` - Background job to fetch full property details (description, coordinates, features)

### Styling Conventions
All styles use SCSS, not CSS. Structure:
- `app/assets/stylesheets/application.scss` - Main manifest
- `app/assets/stylesheets/config/` - Variables, colors, fonts, Bootstrap customization
- `app/assets/stylesheets/components/` - Reusable component styles
- `app/assets/stylesheets/pages/` - Page-specific styles

### Environment
- Uses `dotenv-rails` for environment variables in development/test
- Create `.env` file for local configuration
- Required: `EASYBROKER_API_KEY` (staging API key)

## Code Standards
- All code and comments must be written in English

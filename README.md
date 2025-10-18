# metapy
Getting started quickly in Python projects, inspired by [unravel/metaclj](https://github.com/unravel-team/metaclj)

## How to use me
Copy the Makefile into your Python project

Running the `make` command will show you the following (below).

You should **follow this list**:
- Start from the `make venv` command
- Run commands up to `make up` to start infrastructure
- Run `make server` to start the FastAPI server

At this point you will have a fully functional FastAPI server launched. Use the next section to explore the setup

```
help                      # A brief listing of all available commands
venv                      # Create the .venv and the .env files
install-dev-tools         # Install all development tools
build                     # Build the deployment artifact
docker-build              # Build the FastAPI server Dockerfile
docker-compose-build      # Build all the local infra (docker-compose)
up                        # Bring up all the local infra (docker-compose) and synthetic data
migrate                   # Run Alembic database migrations
server                    # Run the FastAPI server locally
check                     # Check that the code is well linted, well typed, well documented
format                    # Format the code using ruff
test                      # Run all the unit tests for the code
test-evals                # Run all the LLM / Eval tests
test-integration          # Run all the integration tests for the code
upgrade-libs              # Upgrade all the deps to their latest versions
clean-cache               # Clean UV Cache (only needed in extreme conditions)
clean                     # Delete any existing artifacts
down                      # Bring down all the local infra (docker-compose)
deploy                    # Deploy the current code to production
deploy-reuse-image        # Deploy only config changes to production, reusing the latest image
rollback                  # Rollback to the previous version stored in backup
prepare                   # Build the latest code and upload image to fly.io. Useful when hot-swapping or migrating
```

### Important Links

*NOTE*: Complete the Getting Started section first

1. **Phoenix Arize Dashboard**: http://localhost:6006/projects
   - When you hit the FastAPI server, you will start seeing traces here
2. **FastAPI OpenAPI Spec**: http://localhost:8000/docs
   - You can try out various routes from here and see how everything works together.

## Recommended Source Code Structure:

```
src/ai_project_name/
├── __init__.py
├── fastapi
│   ├── __init__.py
│   ├── main.py                   # FastAPI entry point
│   ├── models.py                 # FASTAPI Pydantic models
│   └── security.py               # Authentication/authorization
├── shared
│   ├── __init__.py
│   ├── config.py                 # Application configuration
|   ├── database.py               # SQLAlchemy models & PostgreSQL
├── activities.py                 # Al Temporal activities
├── agents                        # All Agent logic
│   ├── __init__.py
│   ├── code_agent.py
│   ├── memory.py
│   └── search_agent.py
├── tools                         # All Tool logic
│   ├── __init__.py
│   ├── cql.py
│   └── headcount.py
├── worker.py                     # Temporal Worker entry point
├── models.py                     # Temporal chat workflow models
└── workflows.py                  # All Temporal workflows
```

## Recommended tooling:

### Direnv: For loading and unloading `.env` files correctly.

[direnv](https://direnv.net/) is a fantastic tool for managing environment variables correctly.

The standard configuration for it is available at: [direnv.toml](configuration/direnv.toml). Copy this file to: `~/.config/direnv/direnv.toml`

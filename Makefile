.PHONY: check-tagref check-ruff check-pyright check format test upgrade-libs install-ruff install-pytest install-pyright install-tagref install-dev-tools build api-server worker sync venv deploy clean-cache clean

HOME := $(shell echo $$HOME)
HERE := $(shell echo $$PWD)

# Set bash instead of sh for the @if [[ conditions,
# and use the usual safety flags:
SHELL = /bin/bash -Eeu

.DEFAULT_GOAL := help

help:    ## A brief listing of all available commands
	@awk '/^[a-zA-Z0-9_-]+:.*##/ { \
		printf "%-25s # %s\n", \
		substr($$1, 1, length($$1)-1), \
		substr($$0, index($$0,"##")+3) \
	}' $(MAKEFILE_LIST)

.env: .env_sample    ## Copy .env_sample to .env if .env doesn't exist
	@if [ ! -f .env ]; then \
		echo "Creating .env from .env_sample..."; \
		cp .env_sample .env; \
		echo "✓ .env created. Please edit it with your actual values."; \
	else \
		echo ".env already exists, skipping..."; \
	fi

sync:
	uv sync --frozen --no-cache

.venv: sync

venv: .venv .env    ## Create the .venv and the .env files
	@echo "Virtual environment created at .venv/"
	@echo "To activate it:"
	@echo "  bash/zsh: source .venv/bin/activate"
	@echo "  fish:     source .venv/bin/activate.fish"

pyproject.toml:
	@if [ ! -f pyproject.toml ]; then \
		echo "Creating pyproject.toml..."; \
		echo '[build-system]' > pyproject.toml; \
		echo 'requires = ["hatchling"]' >> pyproject.toml; \
		echo 'build-backend = "hatchling.build"' >> pyproject.toml; \
		echo '' >> pyproject.toml; \
		echo '[project]' >> pyproject.toml; \
		echo 'name = "your-project-name"' >> pyproject.toml; \
		echo 'version = "0.1.0"' >> pyproject.toml; \
		echo 'description = ""' >> pyproject.toml; \
		echo 'authors = []' >> pyproject.toml; \
		echo '' >> pyproject.toml; \
	fi

install-ruff: pyproject.toml
	uv add ruff --group dev
	@if ! grep -q "\[tool.ruff.lint\]" pyproject.toml; then \
		echo '' >> pyproject.toml; \
		echo '[tool.ruff.lint]' >> pyproject.toml; \
		echo 'select = [' >> pyproject.toml; \
		echo '    # pycodestyle' >> pyproject.toml; \
		echo '    "E",' >> pyproject.toml; \
		echo '    # Pyflakes' >> pyproject.toml; \
		echo '    "F",' >> pyproject.toml; \
		echo '    # pyupgrade' >> pyproject.toml; \
		echo '    "UP",' >> pyproject.toml; \
		echo '    # flake8-bugbear' >> pyproject.toml; \
		echo '    "B",' >> pyproject.toml; \
		echo '    # flake8-simplify' >> pyproject.toml; \
		echo '    "SIM",' >> pyproject.toml; \
		echo '    # isort' >> pyproject.toml; \
		echo '    "I",' >> pyproject.toml; \
		echo ']' >> pyproject.toml; \
		echo 'ignore = ["E501"]' >> pyproject.toml; \
	fi

install-pytest: pyproject.toml
	uv add pytest pytest-asyncio --group dev
	@if ! grep -q "\[tool.pytest.ini_options\]" pyproject.toml; then \
		echo '' >> pyproject.toml; \
		echo '[tool.pytest.ini_options]' >> pyproject.toml; \
		echo 'testpaths = ["tests"]' >> pyproject.toml; \
		echo 'addopts = "-v --tb=short"' >> pyproject.toml; \
		echo 'asyncio_mode = "auto"' >> pyproject.toml; \
		echo 'log_cli = true' >> pyproject.toml; \
		echo 'log_cli_level = "INFO"' >> pyproject.toml; \
		echo 'log_cli_format = "%(asctime)s [%(levelname)8s] %(message)s (%(filename)s:%(lineno)s)"' >> pyproject.toml; \
		echo 'asyncio_default_fixture_loop_scope = "function"' >> pyproject.toml; \
	fi

install-pyright:
	uv add pyright --group dev

CONVENTIONS.md:
	@echo "Download the CONVENTIONS.md file from the [[https://github.com/unravel-team/metapy][metapy]] project"

.aider.conf.yml:
	@echo "Download the .aider.conf.yml file from the [[https://github.com/unravel-team/metapy][metapy]] project"

.gitignore:
	@echo "Download the .gitignore file from the [[https://github.com/unravel-team/metapy][metapy]] project"

install-tagref:
	@if ! command -v tagref >/dev/null 2>&1; then \
		echo "tagref executable not found. Please install it from https://github.com/stepchowfun/tagref?tab=readme-ov-file#installation-instructions"; \
		exit 1; \
	fi

install-dev-tools: install-ruff install-pytest install-pyright install-tagref CONVENTIONS.md .aider.conf.yml .gitignore    ## Install all development tools

upgrade-libs:    ## Install all the deps to their latest versions
	uv sync --upgrade

check-tagref: install-tagref
	tagref

check-ruff:
	uv run ruff check -n

check-pyright:
	uv run pyright

check: check-ruff check-pyright check-tagref    ## Check that the code is well linted, well typed, well documented
	@echo "All checks passed!"

format:  ## Format the code using ruff
	uv run ruff check -n --fix
	uv run ruff format

build: check     ## Build the deployment artifact
	uv build

up:     ## Bring up all the local infra (docker-compose) and synthetic data
	docker compose up

logs:
	docker compose logs

test:    ## Run all the tests for the code
	uv run pytest

api-server:    ## Run the FastAPI server locally
	uv run -m unravel.fastapi.main

worker:   ## Run the Worker server locally
	uv run -m unravel.temporal.worker

clean-cache:    ## Clean UV Cache (only needed in extreme conditions)
	@echo "Cleaning cache! This removes all downloaded deps!"
	uv cache clean

clean:     ## Delete any existing artifacts
	find . -type f -name "*.pyc" -delete
	find . -type d -name "__pycache__" -exec rm -rf {} +
	rm -rf build/
	rm -rf dist/
	rm -rf *.egg-info/

down:       ## Bring down all the local infra (docker-compose)
	docker compose down -v

deploy: build    ## Deploy the current code to production
	@echo "Run temporal deployment commands here!"

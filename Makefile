.PHONY: check-tagref check-ruff check-pyright check test upgrade-libs build api-server worker sync venv deploy clean clean-cache

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

CONVENTIONS.md:   ## Check if the CONVENTIONS file exists, if not, inform the user
	@echo "Download the CONVENTIONS.md file from the [[https://github.com/unravel-team/metapy][metapy]] project"

.aider.conf.yml:   ## Check if the Aider configuration file exists, if not, inform the user
	@echo "Download the .aider.conf.yml file from the [[https://github.com/unravel-team/metapy][metapy]] project"

check-tagref:
	@if ! command -v tagref >/dev/null 2>&1; then \
		echo "tagref executable not found. Please install it from https://github.com/stepchowfun/tagref/releases/"; \
		exit 1; \
	fi
	tagref

check-ruff:
	uv run ruff check -n --fix

check-pyright:
	uv run pyright

check: check-ruff check-pyright check-tagref    ## Check that the code is well linted, well typed, well documented
	@echo "All checks passed!"

format: check-ruff
	uv run ruff format

test:    ## Run all the tests for the code
	uv run pytest

upgrade-libs:    ## Install all the deps to their latest versions
	uv sync --upgrade

install-dev-tools:    ## Install development tools (ruff, pyright, pytest)
	uv add ruff pyright pytest --group dev

build: check    ## Build the deployment artifact
	uv build

deploy: build    ## Deploy the current code to production
	@echo "Run temporal deployment commands here!"

api-server:    ## Run the FastAPI server locally
	uv run python run_api.py

worker:   ## Run the Worker server locally
	uv run python run_worker.py

clean-cache:    ## Clean UV Cache (only needed in extreme conditions)
	@echo "Cleaning cache! This removes all downloaded deps!"
	uv cache clean

clean:     ## Delete any existing artifacts
	find . -type f -name "*.pyc" -delete
	find . -type d -name "__pycache__" -exec rm -rf {} +
	rm -rf build/
	rm -rf dist/
	rm -rf *.egg-info/

sync:
	uv sync --frozen --no-cache

.venv: sync

venv: .venv    ## Create the virtual env and activate it
	@echo "Virtual environment created at .venv/"
	@echo "To activate it:"
	@echo "  bash/zsh: source .venv/bin/activate"
	@echo "  fish:     source .venv/bin/activate.fish"

.PHONY: help build test run lint deploy clean

SERVICE_NAME := payment-service
IMAGE_TAG ?= latest

help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

build: ## Build the Docker image
	docker build -t $(SERVICE_NAME):$(IMAGE_TAG) .

test: ## Run unit tests with coverage
	pytest app/tests/ -v --cov=app/src --cov-report=term-missing --cov-fail-under=80

run: ## Run the service locally
	cd app/src && uvicorn main:app --reload --port 8080

lint: ## Run linter and type checker
	ruff check app/src/
	mypy app/src/ --ignore-missing-imports

fmt: ## Auto-format code
	ruff format app/src/ app/tests/

docker-run: build ## Build and run in Docker
	docker run -p 8080:8080 --env-file .env $(SERVICE_NAME):$(IMAGE_TAG)

plan: ## Run Terraform plan
	cd infra && terraform plan -var="image_tag=$(IMAGE_TAG)"

apply: ## Run Terraform apply
	cd infra && terraform apply -var="image_tag=$(IMAGE_TAG)"

clean: ## Remove build artifacts
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
	rm -rf .pytest_cache .mypy_cache .ruff_cache htmlcov

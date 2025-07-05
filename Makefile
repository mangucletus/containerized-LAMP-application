# Makefile
.PHONY: help init plan apply destroy build push logs clean

# Default target
help:
	@echo "Available commands:"
	@echo "  init     - Initialize Terraform"
	@echo "  plan     - Plan Terraform deployment"
	@echo "  apply    - Apply Terraform deployment"
	@echo "  destroy  - Destroy infrastructure"
	@echo "  build    - Build and push Docker image"
	@echo "  logs     - View application logs"
	@echo "  clean    - Clean up local files"
	@echo "  dev      - Start local development environment"

init:
	cd terraform && terraform init

plan:
	cd terraform && terraform plan

apply:
	./scripts/deploy.sh

destroy:
	./scripts/cleanup.sh

build:
	./scripts/build-and-push.sh

logs:
	aws logs tail /aws/ecs/student-record-system --follow

clean:
	docker system prune -f
	docker volume prune -f

dev:
	docker-compose up -d
	@echo "Application available at http://localhost:8080"

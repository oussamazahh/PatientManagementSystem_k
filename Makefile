# 🛠️ Variables
SERVICES = auth-service patient-service api-gateway billing-service analytics-service
DATABASES = auth-db patient-db
KAFKA = kafka
CONFIG_DIR = k3s
DOCKER_DIR = docker

# 🌈 Colors
RED=\033[0;31m
GREEN=\033[0;32m
YELLOW=\033[0;33m
BLUE=\033[0;34m
NC=\033[0m

.PHONY: help build-all push-all deploy-all clean-all

help: ## 📖 Show this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "${YELLOW}%-20s${NC} %s\n", $$1, $$2}' $(MAKEFILE_LIST)

## —— Docker Management 🐳 ——
build-images: ## 🔨 Build all Docker images
	@echo "\n${BLUE}🏗️  Building Docker images...${NC}"
	@for service in $(SERVICES); do \
		echo "${GREEN}🐳 Building $$service${NC}"; \
		docker build -t $$service:latest $(DOCKER_DIR)/$$service; \
	done

## —— Kubernetes Secrets & Configs 🔑 ——
create-secrets: ## 🔐 Create Kubernetes secrets
	@echo "\n${BLUE}🔑 Creating secrets...${NC}"
	@kubectl create secret generic auth-db-secret \
		--from-literal=username=admin \
		--from-literal=password=admin --dry-run=client -o yaml | kubectl apply -f -
	@kubectl create secret generic patient-db-secret \
		--from-literal=username=admin \
		--from-literal=password=admin --dry-run=client -o yaml | kubectl apply -f -
	@kubectl create secret generic jwt-secret \
		--from-literal=secret=g1brIEgHUckFn02lhSOxQ6wQWvEc9hLn6mmQFb5D7pRAQnj5xrhyyxtKvyjxiDyLbsHirmcPRtEjiZRxYkLpSmt0Sa0GYVML/MPbgRRQ3pE= --dry-run=client -o yaml | kubectl apply -f -

create-configs: ## 📝 Create config maps
	@echo "\n${BLUE}📄 Creating config maps...${NC}"
	@kubectl apply -f $(CONFIG_DIR)/databases/patient-db/configmap.yaml

## —— Kubernetes Deployments 🚀 ——
deploy-databases: ## 🗃️ Deploy databases
	@echo "\n${BLUE}💾 Deploying databases...${NC}"
	@for db in $(DATABASES); do \
		echo "${GREEN}🚀 Deploying $$db${NC}"; \
		kubectl apply -f $(CONFIG_DIR)/databases/$$db/; \
	done

deploy-kafka: ## 📮 Deploy Kafka
	@echo "\n${BLUE}🚇 Deploying Kafka...${NC}"
	@kubectl apply -f $(CONFIG_DIR)/$(KAFKA)/

deploy-services: ## 🛎️ Deploy microservices
	@echo "\n${BLUE}🛠️ Deploying services...${NC}"
	@for service in $(SERVICES); do \
		echo "${GREEN}🚀 Deploying $$service${NC}"; \
		kubectl apply -f $(CONFIG_DIR)/$$service/; \
	done

## —— Full Deployment Pipeline ——
deploy-all: create-secrets create-configs deploy-databases deploy-kafka deploy-services ## 🏗️ Full deployment pipeline

## —— Maintenance 🧹 ——
clean: ## 🧼 Clean up all resources
	@echo "\n${RED}🧹 Cleaning up resources...${NC}"
	@for service in $(SERVICES); do \
		echo "${RED}❌ Deleting $$service${NC}"; \
		kubectl delete -f $(CONFIG_DIR)/$$service/; \
	done
	@for db in $(DATABASES); do \
		echo "${RED}❌ Deleting $$db${NC}"; \
		kubectl delete -f $(CONFIG_DIR)/databases/$$db/; \
	done
	@kubectl delete -f $(CONFIG_DIR)/$(KAFKA)/
	@kubectl delete secret auth-db-secret patient-db-secret jwt-secret

## —— Monitoring 👀 ——
status: ## 📊 Check cluster status
	@echo "\n${BLUE}📡 Cluster status:${NC}"
	@kubectl get pods -o wide
	@echo "\n${BLUE}🔌 Services:${NC}"
	@kubectl get svc
	@echo "\n${BLUE}💾 Persistent volumes:${NC}"
	@kubectl get pvc

## —— Shortcuts 🏎️ ——
up: build-images deploy-all status ## 👆 Build and deploy everything
down: clean ## 🛑 Tear down everything
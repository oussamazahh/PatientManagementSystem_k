# 🛠️ Environment Variables
SERVICES        := auth-service patient-service api-gateway billing-service analytics-service
DATABASES       := databases/auth-db databases/patient-db
KAFKA          := kafka
CONFIG_DIR     := k3s
DOCKER_DIR     := docker
CLUSTER_NAME   := mycluster
KUBECONFIG     := ${HOME}/.kube/config

# 🌈 Color Definitions
RED            =\033[0;31m
GREEN          =\033[0;32m
YELLOW         =\033[0;33m
BLUE           =\033[0;34m
NC             =\033[0m

.PHONY: help install build deploy clean status up down

help: ## 📖 Show this help menu
	@echo "\n${BLUE}Available commands:${NC}"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  ${YELLOW}%-20s${NC} %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""

install: ## 🌐 Install k3s cluster and dependencies
	@echo "\n${BLUE}🚀 Installing development environment...${NC}"
	@sudo apt-get update -qq && sudo apt-get install -y -qq curl docker.io
	@curl -sL https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
	@curl -LOs "https://dl.k8s.io/release/$$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
	@sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
	@k3d cluster create $(CLUSTER_NAME) -p "4004:30004@loadbalancer" --wait
	@mkdir -p $$(dirname $(KUBECONFIG)) && sudo cp /etc/rancher/k3s/k3s.yaml $(KUBECONFIG) && sudo chown $$USER $(KUBECONFIG)
	@echo "\n${GREEN}✅ Cluster ready! Verify with: kubectl cluster-info${NC}"

build: ## 🐳 Build all Docker images
	@echo "\n${BLUE}🏭 Building microservices...${NC}"
	@for service in $(SERVICES); do \
		echo "${GREEN}🔨 Building $$service...${NC}"; \
		docker build -t $$service:latest $(DOCKER_DIR)/$$service || { echo "${RED}❌ Build failed for $$service${NC}"; exit 1; }; \
	done
	@echo "\n${GREEN}🎉 All images built successfully!${NC}"

deploy: ## 🚀 Deploy entire system to Kubernetes
	@echo "\n${BLUE}🌌 Deploying system components...${NC}"
	
	@echo "\n${YELLOW}🔐 Creating secrets...${NC}"
	@kubectl create secret generic auth-db-secret \
		--from-literal=username=admin \
		--from-literal=password=admin --dry-run=client -o yaml | kubectl apply -f - || true
	@kubectl create secret generic patient-db-secret \
		--from-literal=username=admin \
		--from-literal=password=admin --dry-run=client -o yaml | kubectl apply -f - || true
	@kubectl create secret generic jwt-secret \
		--from-literal=secret=$$(openssl rand -base64 512) --dry-run=client -o yaml | kubectl apply -f - || true
	
	@echo "\n${YELLOW}🗄️ Deploying databases...${NC}"
	@for db in $(DATABASES); do \
		echo "${GREEN}📦 Deploying $$db...${NC}"; \
		kubectl apply -f $(CONFIG_DIR)/$$db/ || { echo "${RED}❌ Database deployment failed${NC}"; exit 1; }; \
	done
	
	@echo "\n${YELLOW}📮 Deploying Kafka...${NC}"
	@kubectl apply -f $(CONFIG_DIR)/$(KAFKA)/ || { echo "${RED}❌ Kafka deployment failed${NC}"; exit 1; }
	
	@echo "\n${YELLOW}🛠️ Deploying services...${NC}"
	@for service in $(SERVICES); do \
		echo "${GREEN}🚀 Deploying $$service...${NC}"; \
		kubectl apply -f $(CONFIG_DIR)/$$service/ || { echo "${RED}❌ Service deployment failed for $$service${NC}"; exit 1; }; \
	done
	@kubectl create -f k3s/ingress.yaml	
	@echo "\n${GREEN}🏁 Deployment completed successfully!${NC}"

clean: ## 🧹 Clean up all cluster resources
	@echo "\n${BLUE}🧼 Cleaning up cluster...${NC}"
	@for service in $(SERVICES); do \
		echo "${RED}❌ Removing $$service...${NC}"; \
		kubectl delete -f $(CONFIG_DIR)/$$service/ --ignore-not-found; \
	done
	@for db in $(DATABASES); do \
		echo "${RED}❌ Removing $$db...${NC}"; \
		kubectl delete -f $(CONFIG_DIR)/$$db/ --ignore-not-found; \
	done
	@kubectl delete -f $(CONFIG_DIR)/$(KAFKA)/ --ignore-not-found
	@kubectl delete secret auth-db-secret patient-db-secret jwt-secret --ignore-not-found
	@kubectl delete -f k3s/ingress.yaml
	@echo "\n${GREEN}🗑️  Cluster resources removed!${NC}"

status: ## 📊 Show cluster status
	@echo "\n${BLUE}📡 Cluster Status:${NC}"
	@kubectl get pods -o wide
	@echo "\n${BLUE}🔌 Services:${NC}"
	@kubectl get svc -o wide
	@echo "\n${BLUE}💾 Persistent Volumes:${NC}"
	@kubectl get pvc -o wide

up: build deploy status ## 🔼 Full deployment pipeline (build + deploy + status)

down: clean ## 🔽 Tear down entire cluster

lint: ## 🔍 Validate Kubernetes manifests
	@echo "\n${BLUE}🔎 Linting Kubernetes manifests...${NC}"
	@for resource in $(SERVICES) $(DATABASES) $(KAFKA); do \
		kubectl apply --validate=true --dry-run=server -f $(CONFIG_DIR)/$$resource/; \
	done
	@echo "\n${GREEN}✅ All manifests validated successfully!${NC}"

watch: ## 👀 Watch real-time cluster events
	@kubectl get pods --watch

logs: ## 📝 Tail logs for all services
	@for pod in $$(kubectl get pods -o name); do \
		echo "\n${BLUE}📜 Logs for $$pod ${NC}"; \
		kubectl logs $$pod --tail=50 --all-containers; \
	done

restart: ## 🔄 Restart all deployments
	@for deployment in $$(kubectl get deployments -o name); do \
		echo "${GREEN}🔄 Restarting $$deployment...${NC}"; \
		kubectl rollout restart $$deployment; \
	done

# 🛠️ Variables
SERVICES = auth-service patient-service api-gateway billing-service analytics-service
DATABASES = auth-db patient-db
KAFKA = kafka
CONFIG_DIR = k3s
DOCKER_DIR = docker

.PHONY: help install build deploy clean status up down

help:  ## Show available commands
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install:  ## Install k3s and dependencies
	@echo "\n🛠️  Installing k3s environment..."
	@sudo apt-get update && sudo apt-get install -y curl docker.io
	@curl -sL https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
	@curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
	@sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
	@k3d cluster create mycluster -p "8080:80@loadbalancer"
	@mkdir -p ~/.kube && sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config && sudo chown $USER ~/.kube/config
	@echo "\n✅ Kubernetes cluster ready! Verify with: kubectl cluster-info"

build:  ## Build Docker images
	@echo "\n🐳 Building microservices..."
	@for service in $(SERVICES); do \
		echo "🔨 Building $$service..."; \
		docker build -t $$service:latest $(DOCKER_DIR)/$$service || exit 1; \
	done
	@echo "\n🎉 All images built successfully!"

deploy:  ## Deploy to Kubernetes
	@echo "\n🚀 Deploying system components..."
	@echo "\n🔐 Creating secrets..."
	@kubectl create secret generic auth-db-secret --from-literal=username=admin --from-literal=password=admin --dry-run=client -o yaml | kubectl apply -f -
	@kubectl create secret generic patient-db-secret --from-literal=username=admin --from-literal=password=admin --dry-run=client -o yaml | kubectl apply -f -
	@kubectl create secret generic jwt-secret --from-literal=secret=g1brIEgHUckFn02lhSOxQ6wQWvEc9hLn6mmQFb5D7pRAQnj5xrhyyxtKvyjxiDyLbsHirmcPRtEjiZRxYkLpSmt0Sa0GYVML/MPbgRRQ3pE= --dry-run=client -o yaml | kubectl apply -f -
	
	@echo "\n🗄️ Deploying databases..."
	@for db in $(DATABASES); do kubectl apply -f $(CONFIG_DIR)/databases/$$db/; done
	
	@echo "\n📮 Deploying Kafka..."
	@kubectl apply -f $(CONFIG_DIR)/$(KAFKA)/
	
	@echo "\n🛠️ Deploying services..."
	@for service in $(SERVICES); do kubectl apply -f $(CONFIG_DIR)/$$service/; done
	@echo "\n🏁 Deployment complete!"

clean:  ## Remove all resources
	@echo "\n🧹 Cleaning up cluster..."
	@for service in $(SERVICES); do kubectl delete -f $(CONFIG_DIR)/$$service/; done
	@for db in $(DATABASES); do kubectl delete -f $(CONFIG_DIR)/databases/$$db/; done
	@kubectl delete -f $(CONFIG_DIR)/$(KAFKA)/
	@kubectl delete secret auth-db-secret patient-db-secret jwt-secret
	@echo "\n🗑️  Cluster resources removed!"

status:  ## Show cluster status
	@echo "\n📡 Cluster Status:"
	@kubectl get pods -o wide
	@echo "\n🔌 Services:"
	@kubectl get svc
	@echo "\n💾 Storage:"
	@kubectl get pvc

up: build deploy status  ## Full deployment pipeline

down: clean  ## Tear down everything

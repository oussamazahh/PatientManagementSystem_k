NAMESPACE=internal

.PHONY: all apply clean status logs

all: apply status

apply:
	@echo "🚀 Applying Kubernetes namespace..."
	kubectl apply -f namespaces.yaml
	@echo "✅ Namespace applied!"

	@echo "🚀 Applying ConfigMaps and Secrets..."
	kubectl apply -f configs/
	@echo "✅ Configs and Secrets applied!"

	@echo "🚀 Deploying StatefulSets (Databases)..."
	kubectl apply -f statefulsets/
	@echo "✅ StatefulSets deployed!"

	@echo "🚀 Deploying Microservices..."
	kubectl apply -f deployments/
	@echo "✅ Deployments applied!"

	@echo "🚀 Creating Services..."
	kubectl apply -f services/
	@echo "✅ Services applied!"

	@echo "🚀 Applying Ingress..."
	kubectl apply -f ingress.yaml
	@echo "✅ Ingress applied!"

	@echo "🎉 Deployment complete!"

clean:
	@echo "🔥 Deleting all Kubernetes resources..."
	kubectl delete namespace $(NAMESPACE)
	@echo "✅ Namespace and all resources deleted!"

status:
	@echo "📌 Checking pod status..."
	kubectl get pods -n $(NAMESPACE)
	@echo "📌 Checking services..."
	kubectl get services -n $(NAMESPACE)
	@echo "📌 Checking ingress..."
	kubectl get ingress -n $(NAMESPACE)

logs:
	@echo "📜 Fetching logs for all pods..."
	kubectl logs -l app=auth-service -n $(NAMESPACE) --tail=100
	kubectl logs -l app=patient-service -n $(NAMESPACE) --tail=100
	kubectl logs -l app=api-gateway -n $(NAMESPACE) --tail=100
	kubectl logs -l app=billing-service -n $(NAMESPACE) --tail=100
	kubectl logs -l app=analytics-service -n $(NAMESPACE) --tail=100
	kubectl logs -l app=kafka -n $(NAMESPACE) --tail=100

name: CI/CD Pipeline

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  CLUSTER_NAME: mycluster
  KUBECONFIG: ${{ github.workspace }}/.kube/config

jobs:
  ci-cd:
    runs-on: ubuntu-latest
    timeout-minutes: 20
    steps:
      - name: 🛎 Checkout code
        uses: actions/checkout@v4

      - name: 🐳 Setup Docker
        run: |
          sudo apt-get update
          sudo apt-get install -y ca-certificates curl gnupg
          sudo install -m 0755 -d /etc/apt/keyrings
          curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
          sudo chmod a+r /etc/apt/keyrings/docker.gpg
          echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
          sudo apt-get update
          sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
          sudo usermod -aG docker $USER
          newgrp docker

      - name: ⚙️ Install cluster tools
        run: |
          curl -sL https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
          curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
          sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

      - name: 🛠️ Create cluster
        run: |
          k3d cluster create ${{ env.CLUSTER_NAME }} -p "4004:30004@loadbalancer" --wait
          mkdir -p ${{ env.KUBECONFIG%/*}}
          sudo cp /etc/rancher/k3s/k3s.yaml "${{ env.KUBECONFIG }}"
          sudo chown $USER "${{ env.KUBECONFIG }}"
          kubectl cluster-info

      - name: 🏗 Build images
        run: make build

      - name: 🔍 Lint manifests
        run: make lint

      - name: 🚀 Deploy system
        run: make deploy

      - name: ⏳ Wait for services
        run: |
          kubectl wait --for=condition=available --timeout=300s deployment/api-gateway
          kubectl wait --for=condition=available --timeout=300s deployment/auth-service
          kubectl wait --for=condition=available --timeout=300s deployment/patient-service
          sleep 20  # Wait for ingress propagation

      - name: 🧪 Run tests
        run: |
          curl --retry 5 --retry-delay 10 --retry-connrefused -sSf http://localhost:30004/api-docs/auth | grep -q "openapi" || (echo "❌ Auth Service API Docs Check Failed"; exit 1)
          curl --retry 5 --retry-delay 10 --retry-connrefused -sSf http://localhost:30004/api-docs/patients | grep -q "openapi" || (echo "❌ Patient Service API Docs Check Failed"; exit 1)

      - name: 📊 Final status
        if: always()
        run: make status

      - name: 🧹 Cleanup
        if: always()
        run: make down
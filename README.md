# **Microservices Project - Patient Management System**

This project is a **microservices-based patient management system** built using **Spring Boot**, leveraging **Kafka, gRPC, Spring Security, and PostgreSQL** for scalability and efficiency. Each service is containerized using **Docker** with configurable environment variables for seamless deployment.

---

## **Project Structure**

### **Microservices Included:**
- **Patient Service** (REST API + Swagger)
- **Billing Service** (gRPC + Kafka Producer)
- **Analytics & Notification Services** (Kafka Consumers)
- **Auth Service** (Spring Security + JWT + PostgreSQL)
- **API Gateway** (Spring Cloud Gateway - Reactive)
- **Kafka + Zookeeper** (Event-driven messaging backbone)
- **PostgreSQL Database** (Persistent storage)

---

## **Setup Instructions**

### **1. Clone the Repository**
```sh
git clone https://github.com/your-repo/microservices-project.git
cd microservices-project
```

### **2. Set Up Environment Variables**
Create a **.env** file in the root directory and add the following:
```ini
# Database Configuration
POSTGRES_USER=admin
POSTGRES_PASSWORD=securepassword
POSTGRES_DB=patient_db
POSTGRES_PORT=5432
POSTGRES_HOST=postgres

# Auth Service Configuration
JWT_SECRET=your_jwt_secret
JWT_EXPIRATION=3600000

# Kafka Configuration
KAFKA_BROKER=kafka:9092
KAFKA_TOPIC_PATIENT=patient-topic
KAFKA_TOPIC_BILLING=billing-topic

# gRPC Configuration
GRPC_BILLING_HOST=billing-service
GRPC_BILLING_PORT=9090

# API Gateway Configuration
GATEWAY_PORT=8080
```

### **3. Build and Run the Services with Docker**
Ensure you have **Docker** and **Docker Compose** installed, then run:
```sh
docker-compose up --build -d
```

### **4. Verify Running Containers**
```sh
docker ps
```
You should see all microservices running.

---

## **Accessing the Services**
- **API Gateway**: `http://localhost:4004`

---


## **Stopping the Services**
```sh
docker-compose down
```

---

## **Next Steps**
- Add **Kubernetes Deployment** for scalability 🚀
- Implement **Observability & Monitoring** (Prometheus + Grafana)
- Enhance **Resilience** (Circuit Breakers, Retry Mechanism)

Feel free to contribute and enhance this project!

---

### **🔗 Connect & Discuss!**
🚀 Have ideas or improvements? Let’s collaborate! 💡

📩 **Your Contact Info or GitHub Profile**


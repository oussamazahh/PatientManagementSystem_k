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
- **Kafka** (Event-driven messaging backbone)
- **PostgreSQL Database** (Persistent storage)

---

## **Setup Instructions**

### **1. Clone the Repository**
```sh
git@github.com:Abdellahbounab/PatientManagementSystem.git
cd microservices-project
```

### **2. Set Up Environment Variables**
Create a **.env** file in the root directory and add the following:
```ini
# Auth Service Configuration
JWT_SECRET=g1brIEgHUckFn02lhSOxQ6wQWvEc9hLn6mmQFb5D7pRAQnj5xrhyyxtKvyjxiDyLbsHirmcPRtEjiZRxYkLpSmt0Sa0GYVML/MPbgRRQ3pE=


# Database Configuration
POSTGRES_USER=admin
POSTGRES_PASSWORD=admin
POSTGRES_DB=patientdb
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


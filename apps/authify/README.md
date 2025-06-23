# Authify – User Authentication Service

Authify is a modular user authentication service built in Go using Gin, GORM, and JWT. It provides secure login functionality, role-based access support, and is designed to be easily integrated into microservice or monolith architectures.

---

## 📁 Project Structure

```
authify/
├── cmd/                # Entry point (main.go)
├── config/             # App & DB config loading
├── controllers/        # HTTP handlers (e.g., login)
├── internal/
│   ├── db/             # GORM DB initialization
│   ├── di/             # Manual dependency injection
│   ├── migration/      # DB migration and seed logic
├── middleware/         # (Pluggable JWT middleware - WIP)
├── models/             # GORM models for User, Role, etc.
├── repository/         # DB access logic
├── routes/             # Route registrations
├── services/           # Business logic layer
├── utility/            # Password hashing & JWT utils
├── .env                # Local environment configuration
├── go.mod / go.sum     # Go module dependencies
```

---

## 🚀 Getting Started

### 1. Clone the repo

```bash
git clone https://github.com/your-username/authify.git
cd authify
```

### 2. Create a `development.env` file

```env
PORT=8080
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=password
DB_NAME=authify_db
DB_SSLMODE=disable
JWT_SECRET=your_jwt_secret_here
```

### 3. Run the application

```bash
go run ./cmd
```

---

## ✅ API Endpoint

### `POST /api/login`

Authenticate a user and receive a JWT token.

**Request Body:**
```json
{
  "username": "admin",
  "password": "test123"
}
```

**Response:**
```json
{
  "token": "<jwt_token>"
}
```

---

## 🧪 Running Tests

```bash
go test ./...
```

Includes:
- Unit tests for controllers, services, and repository (mocked with `testify` or `sqlmock`)
- No real DB is required for unit tests

---

## 🐳 Docker Support

### 🔨 Build the Docker image

```bash
docker build -t authify .
```

### ▶️ Run the container

```bash
docker run -p 8080:8080 --env-file .env authify
```

> ℹ️ Make sure you have a `.env` file with all required environment variables (DB, JWT secret, etc.)

---

## 🛠️ Tech Stack

- **Go 1.21+**
- **Gin** – HTTP Router
- **GORM** – ORM for database interactions
- **PostgreSQL** – Primary DB
- **JWT** – Token-based authentication
- **bcrypt** – Secure password hashing
- **sqlmock** – Lightweight DB mocking for unit tests

---

## 🔧 Roadmap

- [ ] Register endpoint
- [ ] JWT-protected route (e.g., `/me`)
- [ ] Middleware for role-based access control
- [ ] Helm chart and Kubernetes manifest
- [ ] Docker & CI/CD

---

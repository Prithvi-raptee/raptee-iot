# Raptee Backend API

High-performance Go-based API for handling telemetry data ingestion, storage, and retrieval for Raptee electric motorcycles.

## 📚 Documentation

This project is documented in detail in the following files:

-   **[SCHEMA.md](docs/SCHEMA.md)**: Database Design, ER Diagrams, and Global Schema definitions.
-   **[BACKEND.md](docs/BACKEND.md)**: API Reference, Data Flow, and Deployment details.

## 🚀 Quick Start

### Prerequisites
-   Go 1.21+
-   Docker
-   PostgreSQL (Local or Remote)

### Running Locally

1.  **Clone & Enter**:
    ```bash
    git clone <repo>
    cd raptee-backend
    ```

2.  **Setup Database**:
    Ensure your `DATABASE_URL` is set (or use the default in `migrate.go` for local dev).
    ```bash
    go run migrate.go
    ```

3.  **Start Server**:
    ```bash
    go run main.go
    ```
    Server runs on `http://localhost:8080`.

## 📂 Project Structure

```
raptee-backend/
├── docs/               # Detailed Documentation
│   ├── SCHEMA.md       # Database Design
│   └── BACKEND.md      # API Reference
├── schema/             # SQL Migration files
│   └── 001_init.sql    # Initial schema (Tables + Global Schemas)
├── Dockerfile          # Docker build definition
├── deploy.go           # Deployment automation script
├── go.mod              # Go module definition
├── main.go             # Main application source code
├── migrate.go          # Database migration script
└── README.md           # This file
```

# Raptee Backend API

High-performance Go-based API for handling telemetry data ingestion, storage, and retrieval for Raptee electric motorcycles.

## Documentation

This project is documented in detail in the following files:

-   **[SCHEMA.md](docs/SCHEMA.md)**: Database Design, ER Diagrams, and Global Schema definitions.
-   **[BACKEND.md](docs/BACKEND.md)**: API Reference, Data Flow, and Deployment details.

## Quick Start

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
    Ensure your `DATABASE_URL` is set (or use the default in `cmd/migrate/main.go` for local dev).
    ```bash
    go run cmd/migrate/main.go
    ```

3.  **Start Server**:
    ```bash
    go run main.go
    ```
    Server runs on `http://localhost:8080`.

4.  **Run Tests**:
    ```bash
    go run cmd/test-api/main.go
    ```

## Project Structure

```
raptee-backend/
├── cmd/                # Command-line applications
│   ├── deploy/         # Deployment automation script
│   ├── migrate/        # Database migration script
│   └── test-api/       # API Integration Tests
├── db/                 # Database connection and schema management
├── docs/               # Detailed Documentation
│   ├── SCHEMA.md       # Database Design
│   └── BACKEND.md      # API Reference
├── handlers/           # HTTP Request Handlers
├── models/             # Data structures
├── schema/             # SQL Migration files
│   ├── 001_init.sql    # Initial schema (Tables + Global Schemas)
│   └── 002_add_cascade_delete.sql # Enable Cascade Delete
├── utils/              # Utility functions
├── Dockerfile          # Docker build definition
├── go.mod              # Go module definition
├── main.go             # Main application entry point
└── README.md           # This file
```

# Raptee Backend API

High-performance Go-based API for handling telemetry data ingestion, storage, and retrieval for Raptee electric motorcycles.

## Overview

This service is designed to handle high-throughput telemetry data from bikes, store it efficiently in PostgreSQL (with PostGIS for geospatial data), and provide APIs for data retrieval and device provisioning.

### Architecture

| Component | Technology | Description |
| :--- | :--- | :--- |
| **Language** | Go (Golang) 1.21 | High concurrency, low latency execution. |
| **Framework** | Gin Web Framework | Fast HTTP web framework. |
| **Database** | PostgreSQL + PostGIS | Relational data + Geospatial indexing. |
| **Driver** | pgx/v5 | High-performance PostgreSQL driver. |
| **Deployment** | Docker + AWS ECR | Containerized deployment. |

## Prerequisites

-   **Go 1.21+**: [Download Go](https://go.dev/dl/)
-   **Docker**: [Download Docker Desktop](https://www.docker.com/products/docker-desktop/)
-   **AWS CLI**: [Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) (Configured with `aws configure`)

## Setup & Configuration

1.  **Clone the repository**:
    ```bash
    git clone <repository-url>
    cd raptee-backend
    ```

2.  **Environment Variables**:
    The application relies on the following environment variables.

    | Variable | Description | Default (if not set) |
    | :--- | :--- | :--- |
    | `DATABASE_URL` | PostgreSQL Connection String | `postgres://postgres:Raptee321@...` (See `migrate.go`) |
    | `PORT` | API Server Port | `8080` |

## Database Management

We use a custom Go script to handle database migrations.

### Workflow
1.  **Create Migration**: Add a new `.sql` file in the `schema/` directory.
    -   Naming convention: `00X_description.sql` (e.g., `002_add_battery_table.sql`).
    -   Files are executed in alphabetical order.
2.  **Run Migrations**:
    ```bash
    go run migrate.go
    ```
    This script checks the `_schema_migrations` table and applies only new SQL files.

## Running Locally

To start the API server locally:

```bash
go run main.go
```

The server will start on `http://localhost:8080`.

## Deployment

We use a Go script to automate the build and push process to AWS Elastic Container Registry (ECR).

### Deployment Steps
1.  **Ensure Docker is running**.
2.  **Ensure AWS CLI is configured** with permissions to push to ECR.
3.  **Run the deployment script**:
    ```bash
    go run deploy.go
    ```

### What `deploy.go` does:
1.  **Authenticates** with AWS ECR using your local AWS credentials.
2.  **Builds** the Docker image (`raptee-go-api:latest`) using the `Dockerfile`.
    -   *Note*: Uses `.dockerignore` to exclude unnecessary files like `deploy.go`.
3.  **Pushes** the image to the configured ECR repository.

## API Reference

### 1. Health Check
-   **GET** `/health`
-   **Response**: `{"status": "ok"}`

### 2. Provision Bike
Registers a new bike or updates metadata for an existing one.
-   **POST** `/api/v1/provision`
-   **Body**:
    ```json
    {
      "bike_id": "RAPTEE_PRO_005",
      "metadata": {
        "color": "Matte Black",
raptee-backend/
├── schema/             # SQL Migration files
│   └── 001_init.sql    # Initial schema
├── Dockerfile          # Docker build definition
├── deploy.go           # Deployment automation script
├── go.mod              # Go module definition
├── main.go             # Main application source code
├── migrate.go          # Database migration script
└── README.md           # Project documentation
```

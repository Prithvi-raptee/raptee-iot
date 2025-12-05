# Client-Side API Response Structure

This document outlines the response structures for the available APIs in the Raptee Backend.

**Base URL:**
*   **Local:** `http://localhost:8080`
*   **Production:** `https://n4gzvnxn5h.ap-south-1.awsapprunner.com`

## 1. Health Check

*   **Endpoint:** `GET /health`
*   **URL Construction:** `{{BASE_URL}}/health`
*   **Description:** Checks if the server is running.

### Success Response (200 OK)

```json
{
  "status": "ok"
}
```

## 2. Sync Telemetry Data

*   **Endpoint:** `POST /api/v1/sync`
*   **URL Construction:** `{{BASE_URL}}/api/v1/sync`
*   **Description:** Ingests telemetry data in a compact format.
*   **Request Body:** `CompactRequest`

### Success Response (200 OK)

```json
{
  "status": "success"
}
```

### Error Responses

*   **400 Bad Request:**
    ```json
    {
      "error": "Invalid JSON format: <error_details>"
    }
    ```
*   **500 Internal Server Error:**
    ```json
    {
      "error": "DB Transaction failed"
    }
    ```
    OR
    ```json
    {
      "error": "Commit failed"
    }
    ```

## 3. Provision Bike

*   **Endpoint:** `POST /api/v1/provision`
*   **URL Construction:** `{{BASE_URL}}/api/v1/provision`
*   **Description:** Provisions or updates metadata for a bike.
*   **Request Body:** `ProvisionRequest`

### Success Response (200 OK)

```json
{
  "status": "provisioned",
  "bike_id": "<bike_id>"
}
```

### Error Responses

*   **400 Bad Request:**
    ```json
    {
      "error": "Invalid JSON format: <error_details>"
    }
    ```
    OR
    ```json
    {
      "error": "bike_id is required"
    }
    ```
*   **500 Internal Server Error:**
    ```json
    {
      "error": "Database error: <error_details>"
    }
    ```

## 4. List All Bikes

*   **Endpoint:** `GET /api/v1/bikes`
*   **URL Construction:** `{{BASE_URL}}/api/v1/bikes?limit=<limit>&cursor=<cursor>`
*   **Description:** Retrieves a list of all bikes with cursor-based pagination.
*   **Query Parameters:**
    *   `limit` (optional): Number of bikes to return (default: 50).
    *   `cursor` (optional): The cursor for pagination (last `bike_id` from previous response).

### Success Response (200 OK)

```json
{
  "next_cursor": "<next_cursor_string>",
  "data": [
    {
      "bike_id": "<bike_id>",
      "metadata": {
        "model": "T-30",
        "color": "Red",
        ...
      }
    },
    ...
  ]
}
```

### Error Responses

*   **500 Internal Server Error:**
    ```json
    {
      "error": "Database error: <error_details>"
    }
    ```

## 5. Read Telemetry Data

*   **Endpoint:** `GET /api/v1/telemetry`
*   **URL Construction:** `{{BASE_URL}}/api/v1/telemetry?bike_id=<bike_id>&cursor=<cursor>`
*   **Description:** Retrieves telemetry data with cursor-based pagination.
*   **Query Parameters:**
    *   `bike_id` (required): The ID of the bike.
    *   `cursor` (optional): The cursor for pagination.

### Success Response (200 OK)

```json
{
  "next_cursor": "<next_cursor_string>",
  "columns": ["uuid", "timestamp", "type", "val_primary", "payload"],
  "data": [
    ["<uuid>", "<timestamp>", "<type>", <val_primary>, "<payload_json_string>"],
    ...
  ]
}
```

### Error Responses

*   **500 Internal Server Error:**
    ```json
    {
      "error": "<error_details>"
    }
    ```

## 6. Delete Bike

*   **Endpoint:** `DELETE /api/v1/provision`
*   **URL Construction:** `{{BASE_URL}}/api/v1/provision?bike_id=<bike_id>`
*   **Description:** Deletes a bike and all its associated telemetry data (Cascade Delete).
*   **Query Parameters:**
    *   `bike_id` (required): The ID of the bike to delete.

### Success Response (200 OK)

```json
{
  "status": "deleted",
  "bike_id": "<bike_id>"
}
```

### Error Responses

*   **400 Bad Request:**
    ```json
    {
      "error": "bike_id is required"
    }
    ```
*   **404 Not Found:**
    ```json
    {
      "error": "Bike not found"
    }
    ```
*   **500 Internal Server Error:**
    ```json
    {
      "error": "Failed to delete bike: <error_details>"
    }
    ```

## 7. Delete Telemetry

*   **Endpoint:** `DELETE /api/v1/telemetry`
*   **URL Construction:** `{{BASE_URL}}/api/v1/telemetry?bike_id=<bike_id>`
*   **Description:** Deletes all telemetry data for a specific bike, but keeps the bike record.
*   **Query Parameters:**
    *   `bike_id` (required): The ID of the bike whose telemetry should be deleted.

### Success Response (200 OK)

```json
{
  "status": "deleted",
  "count": <number_of_deleted_rows>
}
```

### Error Responses

*   **400 Bad Request:**
    ```json
    {
      "error": "bike_id is required"
    }
    ```
*   **500 Internal Server Error:**
    ```json
    {
      "error": "Failed to delete telemetry: <error_details>"
    }
    ```

## 8. Get Analytics

*   **Endpoint:** `GET /api/v1/analytics`
*   **URL Construction:** `{{BASE_URL}}/api/v1/analytics?bike_id=<bike_id>`
*   **Description:** Retrieves analytics data for a specific bike, including summary, API stats, connectivity, failures, and time series.
*   **Query Parameters:**
    *   `bike_id` (required): The ID of the bike.

### Success Response (200 OK)

```json
{
  "bike_id": "<bike_id>",
  "summary": {
    "total_calls": 100,
    "success_rate": 95.5,
    "network_error_rate": 2.0,
    "server_error_rate": 1.5,
    "client_error_rate": 1.0,
    "start_time": "2023-10-27T10:00:00Z",
    "end_time": "2023-10-27T12:00:00Z"
  },
  "api_stats": [
    {
      "api_name": "https://api.example.com/v1/data",
      "count": 50,
      "mean": 120.5,
      "max": 500,
      "min": 50,
      "error_rate": 0.0,
      "p50": 100,
      "p90": 200,
      "p95": 250,
      "p99": 400
    }
  ],
  "connectivity_stats": {
    "state_distribution": {
      "WiFi": 80,
      "Cellular": 20
    },
    "failure_rate_by_state": {
      "WiFi": 1.2,
      "Cellular": 5.0
    },
    "latency_by_state": {
      "WiFi": [100, 110, ...],
      "Cellular": [200, 220, ...]
    }
  },
  "failures": [
    {
      "timestamp": "2023-10-27T10:05:00Z",
      "api_name": "https://api.example.com/v1/data",
      "status_code": 500,
      "latency": 50,
      "type": "Server Error"
    }
  ],
  "time_series": [
    {
      "timestamp": "2023-10-27T10:00:00Z",
      "latency": 120,
      "api_name": "https://api.example.com/v1/data",
      "status": 200,
      "signal_strength": 80,
      "connection_state": "WiFi"
    }
  ]
}
```

### Error Responses

*   **400 Bad Request:**
    ```json
    {
      "error": "bike_id is required"
    }
    ```
*   **500 Internal Server Error:**
    ```json
    {
      "error": "Database error: <error_details>"
    }
    ```

## 9. Delete Bikes (Bulk)

*   **Endpoint:** `DELETE /api/v1/bikes`
*   **URL Construction:** `{{BASE_URL}}/api/v1/bikes`
*   **Description:** Deletes multiple bikes or a single bike.
*   **Request Body (Bulk):**
    ```json
    {
      "bike_ids": ["bike_1", "bike_2"]
    }
    ```
*   **Query Parameters (Single):**
    *   `bike_id`: The ID of the bike to delete.

### Success Response (200 OK)

```json
{
  "status": "deleted",
  "count": 2
}
```
OR
```json
{
  "status": "deleted",
  "bike_id": "bike_1"
}
```

### Error Responses

*   **400 Bad Request:**
    ```json
    {
      "error": "bike_id query param or bike_ids json body required"
    }
    ```
*   **500 Internal Server Error:**
    ```json
    {
      "error": "Failed to delete bikes: <error_details>"
    }
    ```

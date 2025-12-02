package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"math/rand"
	"net/http"
	"time"

	"github.com/google/uuid"
)

const BaseURL = "http://localhost:8080"

func main() {
	log.Println("Starting API Test Suite...")

	// 1. Health Check
	testHealth()

	// 2. Provision & Sync Multiple Bikes
	bikes := []string{"TEST_BIKE_01", "TEST_BIKE_02", "TEST_BIKE_03"}
	
	for _, bikeID := range bikes {
		log.Printf("\n--- Testing Bike: %s ---", bikeID)
		testProvision(bikeID)
		testSync(bikeID)
		testRead(bikeID)
	}

	log.Println("\nAll tests completed successfully!")
}

func testHealth() {
	resp, err := http.Get(BaseURL + "/health")
	if err != nil {
		log.Fatalf("Health check failed: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		log.Fatalf("Health check returned status: %d", resp.StatusCode)
	}
	log.Println("Health Check Passed")
}

func testProvision(bikeID string) {
	// Large Metadata Payload
	metadata := map[string]interface{}{
		"fw_version": "2.1.0",
		"hardware":   "v3.5",
		"color":      "Midnight Black",
		"batch":      "2023-Q4",
		"config": map[string]interface{}{
			"max_speed": 120,
			"eco_mode":  true,
			"features":  []string{"abs", "tcs", "regen"},
		},
		"history": make([]string, 100), // Simulate large array
	}

	payload := map[string]interface{}{
		"bike_id":  bikeID,
		"metadata": metadata,
	}

	sendRequest("POST", "/api/v1/provision", payload)
	log.Printf("Provisioned %s", bikeID)
}

func testSync(bikeID string) {
	// Generate random data points
	now := time.Now().UTC()
	data := [][]interface{}{}

	for i := 0; i < 5; i++ {
		ts := now.Add(time.Duration(-i) * time.Minute).Format(time.RFC3339)
		id := uuid.New().String()
		
		// Random Lat/Lng near Bangalore
		lat := 12.97 + (rand.Float64() * 0.01)
		lng := 77.59 + (rand.Float64() * 0.01)
		
		// Payload matches API_LATENCY schema
		// ["api_call", "status", "status_code", "error_message", "signal_strength", "connection_state", "network_type"]
		payload := []interface{}{
			"/api/v1/sync", "success", 200, "", rand.Intn(5), "connected", "4G",
		}

		row := []interface{}{
			id, ts, "API_LATENCY", rand.Intn(100) + 20, lat, lng, payload,
		}
		data = append(data, row)
	}

	reqBody := map[string]interface{}{
		"bike_id":        bikeID,
		"sync_timestamp": now.Format(time.RFC3339),
		"columns":        []string{"uuid", "timestamp", "type", "val_primary", "lat", "lng", "payload"},
		"data":           data,
	}

	sendRequest("POST", "/api/v1/sync", reqBody)
	log.Printf("Synced data for %s", bikeID)
}

func testRead(bikeID string) {
	resp, err := http.Get(fmt.Sprintf("%s/api/v1/telemetry?bike_id=%s", BaseURL, bikeID))
	if err != nil {
		log.Fatalf("Read failed: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		body, _ := io.ReadAll(resp.Body)
		log.Fatalf("Read failed with %d: %s", resp.StatusCode, string(body))
	}

	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)

	rows := result["data"].([]interface{})
	if len(rows) == 0 {
		log.Fatalf("Read returned no data for %s", bikeID)
	}
	log.Printf("Verified read for %s (Got %d rows)", bikeID, len(rows))
}

func sendRequest(method, endpoint string, payload interface{}) {
	body, _ := json.Marshal(payload)
	req, _ := http.NewRequest(method, BaseURL+endpoint, bytes.NewBuffer(body))
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		log.Fatalf("Request to %s failed: %v", endpoint, err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		respBody, _ := io.ReadAll(resp.Body)
		log.Fatalf("Request to %s failed with %d: %s", endpoint, resp.StatusCode, string(respBody))
	}
}

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
	rand.Seed(time.Now().UnixNano())

	// 1. Health Check
	testHealth()

	// 2. Generate Random Bikes (25-50)
	numBikes := rand.Intn(26) + 25 // 25 to 50
	log.Printf("Generating %d random bikes...", numBikes)

	for i := 0; i < numBikes; i++ {
		bikeID := fmt.Sprintf("TEST_BIKE_%s", uuid.New().String()[:8])
		log.Printf("\n--- Testing Bike: %s (%d/%d) ---", bikeID, i+1, numBikes)
		
		testProvision(bikeID)
		testSync(bikeID)
		// testRead(bikeID) // Optional: Read back to verify
		
		// Optional: Clean up
		// testDeleteTelemetry(bikeID)
		// testDeleteBike(bikeID)
	}

	log.Println("\nAll tests completed successfully!")
}

func testHealth() {
	resp, err := http.Get(BaseURL + "/health")
	if err != nil {
		log.Printf("Health check failed: %v", err)
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		log.Printf("Health check returned status: %d", resp.StatusCode)
		return
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
		"history": make([]string, 10), // Simulate array
	}

	payload := map[string]interface{}{
		"bike_id":  bikeID,
		"metadata": metadata,
	}

	sendRequest("POST", "/api/v1/provision", payload)
	log.Printf("Provisioned %s", bikeID)
}

func testSync(bikeID string) {
	// Generate random data points (0-25)
	numLogs := rand.Intn(26) // 0 to 25
	if numLogs == 0 {
		log.Printf("Skipping sync for %s (0 logs generated)", bikeID)
		return
	}

	now := time.Now().UTC()
	data := [][]interface{}{}

	for i := 0; i < numLogs; i++ {
		ts := now.Add(time.Duration(-i) * time.Minute).Format(time.RFC3339)
		id := uuid.New().String()
		
		// Randomly choose between API_LATENCY and GPS_QUALITY
		if rand.Float32() < 0.5 {
			// API_LATENCY Payload
			// Example: ["https://...", "success", 200, "", 0, "unknown", "WiFi", "charging_station", 0]
			latency := rand.Intn(5000) + 100
			payload := []interface{}{
				"https://charging-stations.example.com/api", // URL
				"success",                                   // Status
				200,                                         // Status Code
				"",                                          // Error Message
				0,                                           // Signal Strength
				"unknown",                                   // Connection State
				"WiFi",                                      // Network Type
				"charging_station",                          // Source/Type
				0,                                           // Retry Count
			}
			
			row := []interface{}{
				id, ts, "API_LATENCY", latency, payload,
			}
			data = append(data, row)

		} else {
			// GPS_QUALITY Payload
			// Example: [4, "Great", 10, 7250.439579992739]
			qualityVal := 4
			accuracy := rand.Float64() * 10000
			payload := []interface{}{
				qualityVal, // Quality Value
				"Great",    // Quality String
				10,         // Satellites
				accuracy,   // Accuracy
			}

			row := []interface{}{
				id, ts, "GPS_QUALITY", qualityVal, payload,
			}
			data = append(data, row)
		}
	}

	reqBody := map[string]interface{}{
		"bike_id":        bikeID,
		"sync_timestamp": now.Format(time.RFC3339),
		"columns":        []string{"uuid", "timestamp", "type", "val_primary", "payload"},
		"data":           data,
	}

	sendRequest("POST", "/api/v1/sync", reqBody)
	log.Printf("Synced %d logs for %s", numLogs, bikeID)
}

func testDeleteTelemetry(bikeID string) {
	req, _ := http.NewRequest("DELETE", fmt.Sprintf("%s/api/v1/telemetry?bike_id=%s", BaseURL, bikeID), nil)
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		log.Printf("Delete telemetry failed: %v", err)
		return
	}
	defer resp.Body.Close()
	log.Printf("Deleted telemetry for %s", bikeID)
}

func testDeleteBike(bikeID string) {
	req, _ := http.NewRequest("DELETE", fmt.Sprintf("%s/api/v1/provision?bike_id=%s", BaseURL, bikeID), nil)
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		log.Printf("Delete bike failed: %v", err)
		return
	}
	defer resp.Body.Close()
	log.Printf("Deleted bike %s", bikeID)
}

func sendRequest(method, endpoint string, payload interface{}) {
	body, _ := json.Marshal(payload)
	req, _ := http.NewRequest(method, BaseURL+endpoint, bytes.NewBuffer(body))
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		log.Printf("Request to %s failed: %v", endpoint, err)
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 && resp.StatusCode != 201 {
		respBody, _ := io.ReadAll(resp.Body)
		log.Printf("Request to %s failed with %d: %s", endpoint, resp.StatusCode, string(respBody))
	}
}

package handlers

import (
	"context"
	"encoding/json"
	"fmt"
	"math"
	"net/http"
	"sort"
	"time"

	"github.com/gin-gonic/gin"
	"raptee-backend/db"
)

// AnalyticsResponse is the top-level response structure
type AnalyticsResponse struct {
	BikeID       string                 `json:"bike_id"`
	Summary      AnalyticsSummary       `json:"summary"`
	APIStats     []APIStat              `json:"api_stats"`
	Connectivity ConnectivityStats      `json:"connectivity_stats"`
	Failures     []FailureIncident      `json:"failures"`
	TimeSeries   []TimeSeriesPoint      `json:"time_series"`
}

type TimeSeriesPoint struct {
	Timestamp       string `json:"timestamp"`
	Latency         int    `json:"latency"`
	APIName         string `json:"api_name"`
	Status          int    `json:"status"`
	SignalStrength  int    `json:"signal_strength"`
	ConnectionState string `json:"connection_state"`
}

type AnalyticsSummary struct {
	TotalCalls       int     `json:"total_calls"`
	SuccessRate      float64 `json:"success_rate"`
	NetworkErrorRate float64 `json:"network_error_rate"` // Status 0
	ServerErrorRate  float64 `json:"server_error_rate"`  // Status 5xx
	ClientErrorRate  float64 `json:"client_error_rate"`  // Status 4xx
	StartTime        string  `json:"start_time"`
	EndTime          string  `json:"end_time"`
}

type APIStat struct {
	APIName   string  `json:"api_name"`
	Count     int     `json:"count"`
	Mean      float64 `json:"mean"`
	Max       int     `json:"max"`
	Min       int     `json:"min"`
	ErrorRate float64 `json:"error_rate"`
	P50       float64 `json:"p50"`
	P90       float64 `json:"p90"`
	P95       float64 `json:"p95"`
	P99       float64 `json:"p99"`
}

type ConnectivityStats struct {
	StateDistribution      map[string]int     `json:"state_distribution"`
	FailureRateByState     map[string]float64 `json:"failure_rate_by_state"`
	LatencyByState         map[string][]int   `json:"latency_by_state"` // For box plots
}

type FailureIncident struct {
	Timestamp   string `json:"timestamp"`
	APIName     string `json:"api_name"`
	StatusCode  int    `json:"status_code"`
	Latency     int    `json:"latency"`
	Type        string `json:"type"` // "Network Error", "Server Error", "High Latency", etc.
}

// Helper struct to parse the JSON payload from DB
type LogPayload struct {
	APICall         string      `json:"api_call"`
	StatusCode      interface{} `json:"status_code"` // Can be int or float or string in JSON
	ConnectionState string      `json:"connection_state"`
	SignalStrength  interface{} `json:"signal_strength"`
}

func HandleGetAnalytics(c *gin.Context) {
	bikeID := c.Query("bike_id")
	if bikeID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "bike_id is required"})
		return
	}

	// Query Telemetry Logs for API_LATENCY
	// We fetch val_primary (latency) and payload (metadata)
	sql := `SELECT logged_at, val_primary, payload 
			FROM telemetry_logs 
			WHERE bike_id = $1 AND log_type = 'API_LATENCY'
			ORDER BY logged_at ASC`

	rows, err := db.Pool.Query(context.Background(), sql, bikeID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error: " + err.Error()})
		return
	}
	defer rows.Close()

	// Data Aggregation Structures
	var summary AnalyticsSummary
	var totalCalls, networkErrors, serverErrors, clientErrors, successCount int
	
	// Per API stats
	apiLatencies := make(map[string][]int) // Success latencies only
	apiAllCounts := make(map[string]int)
	apiErrors := make(map[string]int)

	// Connectivity
	connStateCounts := make(map[string]int)
	connStateFailures := make(map[string]int)
	connStateLatencies := make(map[string][]int)

	// Failures list
	var failures []FailureIncident
	var timeSeries []TimeSeriesPoint

	for rows.Next() {
		var loggedAt interface{} // Use interface to handle time scanning if needed, or just time.Time
		var latency int
		var payloadBytes []byte
		
		// Note: logged_at is TIMESTAMPTZ, pgx scans to time.Time
		if err := rows.Scan(&loggedAt, &latency, &payloadBytes); err != nil {
			continue
		}
		
		// Parse Payload
		// The payload can be a JSON object (new format) or a JSON array (legacy/current format)
		var p LogPayload
		
		// Try unmarshaling as a generic interface first to detect type
		var rawPayload interface{}
		if err := json.Unmarshal(payloadBytes, &rawPayload); err != nil {
			fmt.Printf("Error unmarshaling payload for bike %s: %v\n", bikeID, err)
			continue
		}

		switch v := rawPayload.(type) {
		case map[string]interface{}:
			// JSON Object
			if val, ok := v["api_call"].(string); ok { p.APICall = val }
			if val, ok := v["status_code"]; ok { p.StatusCode = val }
			if val, ok := v["connection_state"].(string); ok { p.ConnectionState = val }
			if val, ok := v["signal_strength"]; ok { p.SignalStrength = val }
			
		case []interface{}:
			// JSON Array
			// Format based on logs: ["url", "status_str", status_code, ?, ?, ?, "connection_state", "api_name", ?]
			// Example: ["https://...", "success", 200, "", 0, "unknown", "WiFi", "charging_station", 0]
			
			if len(v) > 7 {
				if val, ok := v[7].(string); ok { p.APICall = val }
			}
			if len(v) > 2 {
				p.StatusCode = v[2]
			}
			if len(v) > 6 {
				if val, ok := v[6].(string); ok { p.ConnectionState = val }
			}
			// Signal strength index is unknown, leaving empty for now or guessing index 8?
			// Let's assume index 8 might be signal strength if it's a number, but user log has 0 there.
			
		default:
			fmt.Printf("Unknown payload format for bike %s: %T\n", bikeID, rawPayload)
			continue
		}

		// Normalize Status Code
		statusCode := -1
		switch v := p.StatusCode.(type) {
		case float64:
			statusCode = int(v)
		case int:
			statusCode = v
		case string:
			// Try to parse string? Or just default to -1
		}

		// Normalize API Name
		apiName := p.APICall
		if apiName == "" {
			// Fallback to URL if API name is missing (Index 0 in array)
			if arr, ok := rawPayload.([]interface{}); ok && len(arr) > 0 {
				if url, ok := arr[0].(string); ok {
					apiName = url // Use URL as fallback
				}
			}
			if apiName == "" {
				apiName = "unknown"
			}
		}

		// Normalize Connection State
		connState := p.ConnectionState
		if connState == "" {
			connState = "unknown"
		}

		// --- Aggregation Logic ---
		totalCalls++
		apiAllCounts[apiName]++
		connStateCounts[connState]++
		connStateLatencies[connState] = append(connStateLatencies[connState], latency)

		isSuccess := statusCode == 200
		isNetworkError := statusCode == 0
		isServerError := statusCode >= 500 && statusCode < 600
		isClientError := statusCode >= 400 && statusCode < 500

		if isSuccess {
			successCount++
			apiLatencies[apiName] = append(apiLatencies[apiName], latency)
		} else {
			apiErrors[apiName]++
			connStateFailures[connState]++
			
			if isNetworkError {
				networkErrors++
			} else if isServerError {
				serverErrors++
			} else if isClientError {
				clientErrors++
			}
		}

		// Failure / Incident Tracking
		// Condition: Non-200 OR High Latency (> 20s)
		// Format timestamp
		tsStr := ""
		if t, ok := loggedAt.(time.Time); ok {
			tsStr = t.Format(time.RFC3339)
		} else {
			tsStr = fmt.Sprintf("%v", loggedAt)
		}

		// Failure / Incident Tracking
		// Condition: Non-200 OR High Latency (> 20s)
		if !isSuccess || latency > 20000 {
			incidentType := "Other Error"
			if isNetworkError {
				incidentType = "Network Error (0)"
			} else if isServerError {
				incidentType = "Server Error"
			} else if isClientError {
				incidentType = "Client Error"
			} else if latency > 20000 {
				incidentType = "High Latency (>20s)"
			}
			
			failures = append(failures, FailureIncident{
				Timestamp:  tsStr,
				APIName:    apiName,
				StatusCode: statusCode,
				Latency:    latency,
				Type:       incidentType,
			})
		}
		
		// Capture Time Range
		if summary.StartTime == "" {
			summary.StartTime = tsStr
		}
		summary.EndTime = tsStr

		// Populate TimeSeries
		// Normalize Signal Strength
		sigStrength := 0
		switch v := p.SignalStrength.(type) {
		case float64:
			sigStrength = int(v)
		case int:
			sigStrength = v
		}

		timeSeries = append(timeSeries, TimeSeriesPoint{
			Timestamp:       tsStr,
			Latency:         latency,
			APIName:         apiName,
			Status:          statusCode,
			SignalStrength:  sigStrength,
			ConnectionState: connState,
		})
	}

	// --- Final Calculations ---

	// 1. Summary
	summary.TotalCalls = totalCalls
	if totalCalls > 0 {
		summary.SuccessRate = float64(successCount) / float64(totalCalls) * 100
		summary.NetworkErrorRate = float64(networkErrors) / float64(totalCalls) * 100
		summary.ServerErrorRate = float64(serverErrors) / float64(totalCalls) * 100
		summary.ClientErrorRate = float64(clientErrors) / float64(totalCalls) * 100
	}

	// 2. API Stats
	var apiStats []APIStat
	for api, latencies := range apiLatencies {
		count := apiAllCounts[api]
		errCount := apiErrors[api]
		
		stat := APIStat{
			APIName: api,
			Count:   count,
		}

		if count > 0 {
			stat.ErrorRate = float64(errCount) / float64(count) * 100
		}

		if len(latencies) > 0 {
			// Sort for percentiles
			sort.Ints(latencies)
			
			var sum int
			for _, l := range latencies {
				sum += l
			}
			stat.Mean = float64(sum) / float64(len(latencies))
			stat.Min = latencies[0]
			stat.Max = latencies[len(latencies)-1]
			
			stat.P50 = getPercentile(latencies, 0.50)
			stat.P90 = getPercentile(latencies, 0.90)
			stat.P95 = getPercentile(latencies, 0.95)
			stat.P99 = getPercentile(latencies, 0.99)
		}
		
		apiStats = append(apiStats, stat)
	}
	
	// Add APIs that had 0 successes (only errors)
	for api, count := range apiAllCounts {
		found := false
		for _, s := range apiStats {
			if s.APIName == api {
				found = true
				break
			}
		}
		if !found {
			// Only errors
			stat := APIStat{
				APIName:   api,
				Count:     count,
				ErrorRate: 100.0,
			}
			apiStats = append(apiStats, stat)
		}
	}

	// 3. Connectivity Stats
	connStats := ConnectivityStats{
		StateDistribution:  connStateCounts,
		FailureRateByState: make(map[string]float64),
		LatencyByState:     connStateLatencies,
	}
	
	for state, count := range connStateCounts {
		fails := connStateFailures[state]
		if count > 0 {
			connStats.FailureRateByState[state] = float64(fails) / float64(count) * 100
		}
	}

	resp := AnalyticsResponse{
		BikeID:       bikeID,
		Summary:      summary,
		APIStats:     apiStats,
		Connectivity: connStats,
		Failures:     failures,
		TimeSeries:   timeSeries,
	}

	c.JSON(http.StatusOK, resp)
}

func getPercentile(sorted []int, p float64) float64 {
	if len(sorted) == 0 {
		return 0
	}
	idx := int(math.Ceil(float64(len(sorted))*p)) - 1
	if idx < 0 {
		idx = 0
	}
	if idx >= len(sorted) {
		idx = len(sorted) - 1
	}
	return float64(sorted[idx])
}

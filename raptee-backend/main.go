package main

import (
	"context"
	"encoding/base64"
	"fmt"
	"log"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5/pgxpool"
)

var db *pgxpool.Pool

// --- STRUCTS (For JSON Parsing) ---

type CompactRequest struct {
	BikeID    string          `json:"bike_id"`
	Timestamp string          `json:"sync_timestamp"`
	Columns   []string        `json:"columns"`
	Data      [][]interface{} `json:"data"` // List of Lists of "Anything"
}

type ProvisionRequest struct {
	BikeID   string                 `json:"bike_id"`
	Metadata map[string]interface{} `json:"metadata"`
}

// --- MAIN FUNCTION ---

func main() {
	// 1. Database Connection (Uses Environment Variable from AWS)
	dbUrl := os.Getenv("DATABASE_URL")
	if dbUrl == "" {
		log.Fatal("DATABASE_URL environment variable is not set. Cannot connect to RDS.")
	}

	var err error
	db, err = pgxpool.New(context.Background(), dbUrl)
	if err != nil {
		log.Fatalf("Unable to connect to database: %v", err)
	}
	defer db.Close()

	// 2. Router Setup
	r := gin.Default()

	// Enable CORS for Flutter Web (Important for cross-domain calls)
	config := cors.DefaultConfig()
	config.AllowAllOrigins = true // In production, replace with specific domain
	config.AllowHeaders = []string{"Origin", "Content-Length", "Content-Type", "Authorization"}
	r.Use(cors.New(config))

	// 3. Endpoints
	r.GET("/health", func(c *gin.Context) { c.JSON(200, gin.H{"status": "ok"}) })
	r.POST("/api/v1/sync", handleSync)       // Write Ingestion
	r.POST("/api/v1/provision", handleProvision) // Provision/Update Bike
	r.GET("/api/v1/telemetry", handleRead)   // Read Pagination

	// 4. Start Server (AWS App Runner defaults to Port 8080)
	port := os.Getenv("PORT")
	if port == "" { port = "8080" }
	r.Run(":" + port)
}

// --- WRITE HANDLER ---

func handleSync(c *gin.Context) {
	var req CompactRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid JSON format: " + err.Error()})
		return
	}

	// Map columns to indices for dynamic parsing
	colMap := make(map[string]int)
	for i, col := range req.Columns {
		colMap[col] = i
	}
	
	// Helper to extract safely from row array
	get := func(row []interface{}, col string) interface{} {
		if idx, ok := colMap[col]; ok && idx < len(row) {
			return row[idx]
		}
		return nil
	}

	// Prepare Batch Insert
	ctx := context.Background()
	tx, err := db.Begin(ctx)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "DB Transaction failed"})
		return
	}
	defer tx.Rollback(ctx)

	// SQL for Insertion (Uses ON CONFLICT for Idempotency)
	sql := `
	INSERT INTO telemetry_logs (
		log_id, bike_id, logged_at, log_type, val_primary, location, payload
	) VALUES (
		$1, $2, $3, $4, $5, ST_SetSRID(ST_MakePoint($6, $7), 4326), $8
	) ON CONFLICT (bike_id, log_id) DO NOTHING`

	for _, row := range req.Data {
		uuid, _ := get(row, "uuid").(string)
		tsStr, _ := get(row, "timestamp").(string)
		lType, _ := get(row, "type").(string)
		payload := get(row, "payload")

		// Go JSON unmarshals all numbers to float64. We must cast them.
		var valPrimary int
		if v, ok := get(row, "val_primary").(float64); ok { valPrimary = int(v) }

		var lng, lat float64
		if v, ok := get(row, "lng").(float64); ok { lng = v }
		if v, ok := get(row, "lat").(float64); ok { lat = v }

		_, err := tx.Exec(ctx, sql, uuid, req.BikeID, tsStr, lType, valPrimary, lng, lat, payload)
		if err != nil {
			log.Printf("Row insert error: %v", err)
			continue
		}
	}
    // Update Heartbeat (non-critical, can run outside transaction)
    db.Exec(ctx, `INSERT INTO bikes (bike_id, last_seen_at) VALUES ($1, NOW()) ON CONFLICT (bike_id) DO UPDATE SET last_seen_at = NOW()`, req.BikeID)


	if err := tx.Commit(ctx); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Commit failed"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": "success"})
}

// --- PROVISION HANDLER ---

func handleProvision(c *gin.Context) {
	var req ProvisionRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid JSON format: " + err.Error()})
		return
	}

	if req.BikeID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "bike_id is required"})
		return
	}

	// Upsert Bike Metadata
	// Assumes 'metadata' column exists in 'bikes' table as JSONB
	sql := `
	INSERT INTO bikes (bike_id, metadata, last_seen_at)
	VALUES ($1, $2, NOW())
	ON CONFLICT (bike_id)
	DO UPDATE SET metadata = $2, last_seen_at = NOW()`

	_, err := db.Exec(context.Background(), sql, req.BikeID, req.Metadata)
	if err != nil {
		log.Printf("Provision error: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": "provisioned", "bike_id": req.BikeID})
}

// --- READ HANDLER ---

func handleRead(c *gin.Context) {
	bikeID := c.Query("bike_id")
	cursor := c.Query("cursor")
	
	limit := 50
	
	// Build the Seek Query (Cursor-based Pagination)
	sql := `SELECT log_id, logged_at, log_type, val_primary, payload 
			FROM telemetry_logs WHERE bike_id = $1`
	args := []interface{}{bikeID}
	argCounter := 2

	// Add the cursor condition if it exists
	if cursor != "" {
		ts, uuid := decodeCursor(cursor)
		// Tuple Comparison: (logged_at, log_id) < ($2, $3)
		sql += fmt.Sprintf(` AND (logged_at, log_id) < ($%d, $%d)`, argCounter, argCounter+1)
		args = append(args, ts, uuid)
		argCounter += 2
	}

	sql += fmt.Sprintf(` ORDER BY logged_at DESC, log_id DESC LIMIT $%d`, argCounter)
	args = append(args, limit)


	rows, err := db.Query(context.Background(), sql, args...)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	defer rows.Close()

	var data [][]interface{}
	var lastTime time.Time
	var lastUUID string

	for rows.Next() {
		var id, lType string
		var t time.Time
		var val int
		var p []byte // Raw JSON bytes

		rows.Scan(&id, &t, &lType, &val, &p)
		
		// Append as Compact Row: [uuid, time, type, val, payload]
		row := []interface{}{id, t.Format(time.RFC3339), lType, val, string(p)}
		data = append(data, row)

		lastTime = t
		lastUUID = id
	}

	// Determine next cursor: If we got the full limit, there might be more pages.
	nextCursor := ""
	if len(data) == limit {
		nextCursor = encodeCursor(lastTime, lastUUID)
	}

	// Final Compact Response
	c.JSON(http.StatusOK, gin.H{
		"next_cursor": nextCursor,
		"columns":     []string{"uuid", "timestamp", "type", "val_primary", "payload"},
		"data":        data,
	})
}

// --- CURSOR HELPERS ---

func encodeCursor(t time.Time, uuid string) string {
	// Combine timestamp and uuid with a separator, then Base64 encode
	raw := fmt.Sprintf("%s|%s", t.Format(time.RFC3339Nano), uuid)
	return base64.StdEncoding.EncodeToString([]byte(raw))
}

func decodeCursor(c string) (time.Time, string) {
	b, err := base64.StdEncoding.DecodeString(c)
	if err != nil { return time.Time{}, "" }
	
	parts := strings.Split(string(b), "|")
	if len(parts) != 2 { return time.Time{}, "" }
	
	t, err := time.Parse(time.RFC3339Nano, parts[0])
	if err != nil { return time.Time{}, "" }
	
	return t, parts[1]
}
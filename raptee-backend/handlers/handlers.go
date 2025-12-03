package handlers

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"raptee-backend/db"
	"raptee-backend/models"
	"raptee-backend/utils"
)

// --- WRITE HANDLER ---

func HandleSync(c *gin.Context) {
	var req models.CompactRequest
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
	tx, err := db.Pool.Begin(ctx)
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
		rawPayload := get(row, "payload")

		// EXPAND PAYLOAD (If it's an array and we have a global schema)
		var finalPayload interface{} = rawPayload

		// Check if rawPayload is a slice (JSON Array)
		if payloadVals, ok := rawPayload.([]interface{}); ok {
			if keys, hasSchema := db.GlobalSchemas[lType]; hasSchema {
				// Zip Keys + Values
				expanded := make(map[string]interface{})
				for i, val := range payloadVals {
					if i < len(keys) {
						expanded[keys[i]] = val
					}
				}
				finalPayload = expanded
			}
		}

		// Go JSON unmarshals all numbers to float64. We must cast them.
		var valPrimary int
		if v, ok := get(row, "val_primary").(float64); ok {
			valPrimary = int(v)
		}

		var lng, lat float64
		if v, ok := get(row, "lng").(float64); ok {
			lng = v
		}
		if v, ok := get(row, "lat").(float64); ok {
			lat = v
		}

		_, err := tx.Exec(ctx, sql, uuid, req.BikeID, tsStr, lType, valPrimary, lng, lat, finalPayload)
		if err != nil {
			log.Printf("Row insert error: %v", err)
			continue
		}
	}
	// Update Heartbeat (non-critical, can run outside transaction)
	db.Pool.Exec(ctx, `INSERT INTO bikes (bike_id, last_seen_at) VALUES ($1, NOW()) ON CONFLICT (bike_id) DO UPDATE SET last_seen_at = NOW()`, req.BikeID)

	if err := tx.Commit(ctx); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Commit failed"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": "success"})
}

// --- PROVISION HANDLER ---

func HandleProvision(c *gin.Context) {
	var req models.ProvisionRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid JSON format: " + err.Error()})
		return
	}

	if req.BikeID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "bike_id is required"})
		return
	}

	// Upsert Bike Metadata
	sql := `
	INSERT INTO bikes (bike_id, metadata, last_seen_at)
	VALUES ($1, $2, NOW())
	ON CONFLICT (bike_id)
	DO UPDATE SET metadata = $2, last_seen_at = NOW()`

	// Handle nil maps gracefully
	if req.Metadata == nil {
		req.Metadata = make(map[string]interface{})
	}

	_, err := db.Pool.Exec(context.Background(), sql, req.BikeID, req.Metadata)
	if err != nil {
		log.Printf("Provision error: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": "provisioned", "bike_id": req.BikeID})
}

// --- READ HANDLER ---

func HandleRead(c *gin.Context) {
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
		ts, uuid := utils.DecodeCursor(cursor)
		// Tuple Comparison: (logged_at, log_id) < ($2, $3)
		sql += fmt.Sprintf(` AND (logged_at, log_id) < ($%d, $%d)`, argCounter, argCounter+1)
		args = append(args, ts, uuid)
		argCounter += 2
	}

	sql += fmt.Sprintf(` ORDER BY logged_at DESC, log_id DESC LIMIT $%d`, argCounter)
	args = append(args, limit)

	rows, err := db.Pool.Query(context.Background(), sql, args...)
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
		nextCursor = utils.EncodeCursor(lastTime, lastUUID)
	}

	// Final Compact Response
	c.JSON(http.StatusOK, gin.H{
		"next_cursor": nextCursor,
		"columns":     []string{"uuid", "timestamp", "type", "val_primary", "payload"},
		"data":        data,
	})
}

// --- DELETE HANDLERS ---

func HandleDeleteBike(c *gin.Context) {
	bikeID := c.Query("bike_id")
	if bikeID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "bike_id is required"})
		return
	}

	// Because of ON DELETE CASCADE, this deletes the bike AND all its telemetry logs.
	res, err := db.Pool.Exec(context.Background(), "DELETE FROM bikes WHERE bike_id = $1", bikeID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete bike: " + err.Error()})
		return
	}

	if res.RowsAffected() == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Bike not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": "deleted", "bike_id": bikeID})
}

func HandleDeleteTelemetry(c *gin.Context) {
	bikeID := c.Query("bike_id")
	if bikeID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "bike_id is required"})
		return
	}

	// Only delete logs, keep the bike registry
	res, err := db.Pool.Exec(context.Background(), "DELETE FROM telemetry_logs WHERE bike_id = $1", bikeID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete telemetry: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": "deleted", "count": res.RowsAffected()})
}

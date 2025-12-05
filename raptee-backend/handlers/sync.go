package handlers

import (
	"context"
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
	"raptee-backend/db"
	"raptee-backend/models"
)

// HandleSync processes telemetry ingestion
func HandleSync(c *gin.Context) {
	var req models.CompactRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid JSON format: " + err.Error()})
		return
	}

	if err := insertTelemetryBatch(req); err != nil {
		log.Printf("Sync error: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": "success"})
}

func insertTelemetryBatch(req models.CompactRequest) error {
	ctx := context.Background()
	tx, err := db.Pool.Begin(ctx)
	if err != nil {
		return err
	}
	defer tx.Rollback(ctx)

	// Map columns to indices for dynamic parsing
	colMap := make(map[string]int)
	for i, col := range req.Columns {
		colMap[col] = i
	}

	get := func(row []interface{}, col string) interface{} {
		if idx, ok := colMap[col]; ok && idx < len(row) {
			return row[idx]
		}
		return nil
	}

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

		finalPayload := expandPayload(lType, rawPayload)

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
			return err
		}
	}

	// Update Heartbeat
	db.Pool.Exec(ctx, `INSERT INTO bikes (bike_id, last_seen_at) VALUES ($1, NOW()) ON CONFLICT (bike_id) DO UPDATE SET last_seen_at = NOW()`, req.BikeID)

	return tx.Commit(ctx)
}

func expandPayload(logType string, rawPayload interface{}) interface{} {
	// Check if rawPayload is a slice (JSON Array)
	if payloadVals, ok := rawPayload.([]interface{}); ok {
		if keys, hasSchema := db.GlobalSchemas[logType]; hasSchema {
			// Zip Keys + Values
			expanded := make(map[string]interface{})
			for i, val := range payloadVals {
				if i < len(keys) {
					expanded[keys[i]] = val
				}
			}
			return expanded
		}
	}
	return rawPayload
}

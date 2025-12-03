package main

import (
	"os"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"raptee-backend/db"
	"raptee-backend/handlers"
)

// --- MAIN FUNCTION ---

func main() {
	// 1. Database Connection & Schema Loading
	db.Init()
	defer db.Pool.Close()

	// 2. Router Setup
	r := gin.Default()

	// Enable CORS for Flutter Web (Important for cross-domain calls)
	config := cors.DefaultConfig()
	config.AllowAllOrigins = true // In production, replace with specific domain
	config.AllowHeaders = []string{"Origin", "Content-Length", "Content-Type", "Authorization"}
	r.Use(cors.New(config))

	// 3. Endpoints
	r.GET("/health", func(c *gin.Context) { c.JSON(200, gin.H{"status": "ok"}) })
	r.POST("/api/v1/sync", handlers.HandleSync)           // Write Ingestion
	r.POST("/api/v1/provision", handlers.HandleProvision) // Provision/Update Bike
	r.GET("/api/v1/telemetry", handlers.HandleRead)       // Read Pagination
	r.DELETE("/api/v1/provision", handlers.HandleDeleteBike) // Delete Bike
	r.DELETE("/api/v1/telemetry", handlers.HandleDeleteTelemetry) // Delete Telemetry

	// 4. Start Server (AWS App Runner defaults to Port 8080)
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	r.Run(":" + port)
}
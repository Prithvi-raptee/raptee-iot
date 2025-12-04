package main

import (
	"os"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
	"raptee-backend/db"
	"raptee-backend/handlers"
)

// --- MAIN FUNCTION ---

func main() {
	// Load .env file and force override existing env vars
	_ = godotenv.Overload()

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
	r.GET("/api/v1/analytics", handlers.HandleGetAnalytics) // Get Analytics
	r.GET("/health", func(c *gin.Context) { c.JSON(200, gin.H{"status": "ok"}) })
	r.POST("/api/v1/sync", handlers.HandleSync)           // Write Ingestion
	r.POST("/api/v1/provision", handlers.HandleProvision) // Provision/Update Bike
	r.GET("/api/v1/bikes", handlers.HandleListBikes)      // List All Bikes
	r.GET("/api/v1/telemetry", handlers.HandleRead)       // Read Pagination
	r.DELETE("/api/v1/bikes", handlers.HandleDeleteBikes) // Delete Bikes (Bulk/Single)
	r.DELETE("/api/v1/provision", handlers.HandleDeleteBike) // Delete Bike
	r.DELETE("/api/v1/telemetry", handlers.HandleDeleteTelemetry) // Delete Telemetry (For Bulk/Single bikes )

	// 4. Start Server (AWS App Runner defaults to Port 8080)
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	r.Run(":" + port)
}
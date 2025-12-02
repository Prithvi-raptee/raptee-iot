package db

import (
	"context"
	"fmt"
	"log"
	"os"

	"github.com/jackc/pgx/v5/pgxpool"
)

var Pool *pgxpool.Pool
var GlobalSchemas map[string][]string

// Init initializes the database connection and loads schemas
func Init() {
	// 1. Database Connection (Uses Environment Variable from AWS)
	dbUrl := os.Getenv("DATABASE_URL")
	if dbUrl == "" {
		log.Fatal("DATABASE_URL environment variable is not set. Cannot connect to RDS.")
	}

	var err error
	Pool, err = pgxpool.New(context.Background(), dbUrl)
	if err != nil {
		log.Fatalf("Unable to connect to database: %v", err)
	}
	// Note: We don't defer Pool.Close() here because we want the pool to stay open for the lifetime of the app.
	// The main function can handle closing if needed, or we just let it die with the process.

	// 2. Load Global Schemas
	GlobalSchemas = make(map[string][]string)
	rows, err := Pool.Query(context.Background(), "SELECT log_type, fields FROM log_schemas")
	if err != nil {
		log.Printf("Warning: Could not load schemas: %v", err)
	} else {
		defer rows.Close()
		for rows.Next() {
			var lType string
			var fields []string
			if err := rows.Scan(&lType, &fields); err == nil {
				GlobalSchemas[lType] = fields
			}
		}
	}
	fmt.Printf("Loaded %d schemas\n", len(GlobalSchemas))
}

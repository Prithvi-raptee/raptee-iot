package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"sort"
	"strings"

	"github.com/jackc/pgx/v5"
)

// CONFIGURATION
// Replace with your actual connection string for running locally.
// For production, pass this as an environment variable!
const DefaultDBUrl = "postgres://postgres:Raptee321@raptee-telemetry-db.cl6gcoo2mbcg.ap-south-1.rds.amazonaws.com:5432/postgres"

func main() {
	// 1. Get DB Connection
	dbUrl := os.Getenv("DATABASE_URL")
	if dbUrl == "" {
		fmt.Println("No DATABASE_URL env var found. Using default hardcoded config...")
		dbUrl = DefaultDBUrl
	}

	ctx := context.Background()
	conn, err := pgx.Connect(ctx, dbUrl)
	if err != nil {
		log.Fatalf("Unable to connect to database: %v", err)
	}
	defer conn.Close(ctx)

	fmt.Println("Connected to Database. Checking migrations...")

	// 2. Ensure Migration History Table Exists
	_, err = conn.Exec(ctx, `
		CREATE TABLE IF NOT EXISTS _schema_migrations (
			filename TEXT PRIMARY KEY,
			applied_at TIMESTAMPTZ DEFAULT NOW()
		);
	`)
	if err != nil {
		log.Fatalf("Failed to init migration table: %v", err)
	}

	// 3. Read SQL Files from 'schema' folder
	files, err := os.ReadDir("schema")
	if err != nil {
		log.Fatalf("Could not read schema folder: %v", err)
	}

	var sqlFiles []string
	for _, f := range files {
		if strings.HasSuffix(f.Name(), ".sql") {
			sqlFiles = append(sqlFiles, f.Name())
		}
	}
	sort.Strings(sqlFiles) // Ensure we run 001, then 002, etc.

	// 4. Run Pending Migrations
	count := 0
	for _, filename := range sqlFiles {
		// Check if already applied
		var exists bool
		err := conn.QueryRow(ctx, "SELECT EXISTS(SELECT 1 FROM _schema_migrations WHERE filename=$1)", filename).Scan(&exists)
		if err != nil {
			log.Fatalf("Failed to check migration status: %v", err)
		}

		if exists {
			// Skip
			continue
		}

		// Apply Migration
		fmt.Printf("Applying migration: %s... ", filename)
		content, err := os.ReadFile(filepath.Join("schema", filename))
		if err != nil {
			log.Fatalf("\nFailed to read file: %v", err)
		}

		// Transaction ensures we don't apply half a file
		tx, err := conn.Begin(ctx)
		if err != nil {
			log.Fatalf("\nFailed to begin transaction: %v", err)
		}

		// Execute SQL
		if _, err := tx.Exec(ctx, string(content)); err != nil {
			tx.Rollback(ctx)
			log.Fatalf("\nSQL Error in %s: %v", filename, err)
		}

		// Record Success
		if _, err := tx.Exec(ctx, "INSERT INTO _schema_migrations (filename) VALUES ($1)", filename); err != nil {
			tx.Rollback(ctx)
			log.Fatalf("\nFailed to record migration: %v", err)
		}

		if err := tx.Commit(ctx); err != nil {
			log.Fatalf("\nFailed to commit transaction: %v", err)
		}
		fmt.Println("Done!")
		count++
	}

	if count == 0 {
		fmt.Println("Database is up to date.")
	} else {
		fmt.Printf("Successfully applied %d migrations.\n", count)
	}
}
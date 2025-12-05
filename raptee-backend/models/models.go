package models

// CompactRequest represents the structure for sync requests
type CompactRequest struct {
	BikeID    string          `json:"bike_id"`
	Timestamp string          `json:"sync_timestamp"`
	Columns   []string        `json:"columns"`
	Data      [][]interface{} `json:"data"` // List of Lists of "Anything"
}

// ProvisionRequest represents the structure for provision requests
type ProvisionRequest struct {
	BikeID   string                 `json:"bike_id"`
	Metadata map[string]interface{} `json:"metadata"`
}

// Bike represents a bike entity
type Bike struct {
	BikeID   string                 `json:"bike_id"`
	Metadata map[string]interface{} `json:"metadata"`
}

// BikeListResponse represents the response for listing bikes
type BikeListResponse struct {
	NextCursor string `json:"next_cursor"`
	Data       []Bike `json:"data"`
}

// DeleteRequest represents the structure for bulk delete requests
type DeleteRequest struct {
	BikeIDs []string `json:"bike_ids"`
}

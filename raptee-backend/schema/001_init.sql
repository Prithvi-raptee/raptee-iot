-- 1. CLEANUP (Optional: Deletes old tables so you start fresh)
--    If this is a brand new DB, these lines will just be skipped.
DROP TABLE IF EXISTS telemetry_logs CASCADE;
DROP TABLE IF EXISTS bikes CASCADE;

-- 2. ENABLE EXTENSIONS
--    Required for the 'location' column (Heatmaps)
CREATE EXTENSION IF NOT EXISTS postgis;

-- 3. CREATE REGISTRY TABLE (The Parent)
--    Stores the list of valid devices.
CREATE TABLE bikes (
    bike_id TEXT PRIMARY KEY,               -- e.g., "RAPTEE_001"
    last_seen_at TIMESTAMPTZ DEFAULT NOW(), -- Auto-updates on sync
    metadata JSONB                          -- Flexible storage (Color, FW Ver)
);

-- 4. CREATE LOGS TABLE (The Child)
--    Stores the massive stream of data.
CREATE TABLE telemetry_logs (
    log_id UUID,                            -- Generated on the Bike
    bike_id TEXT NOT NULL REFERENCES bikes(bike_id), -- FK: Must exist in 'bikes'
    logged_at TIMESTAMPTZ NOT NULL,         -- When the event happened
    log_type TEXT NOT NULL,                 -- 'API_LATENCY', 'GPS_JUMP'
    
    -- Extracted values for fast sorting/graphing
    val_primary INTEGER,                    -- Latency (ms) or Signal (%)
    
    -- Geospatial Point (Lat/Lng) for Maps
    location GEOGRAPHY(POINT, 4326),
    
    -- Full Raw Data (for debugging details)
    payload JSONB,
    
    -- COMPOSITE PRIMARY KEY
    -- Ensures we never store the same log ID for the same bike twice.
    CONSTRAINT pk_telemetry UNIQUE (bike_id, log_id)
);

-- 5. CREATE CRITICAL INDEXES
--    Makes "Infinite Scroll" instant (Seek Method)
CREATE UNIQUE INDEX idx_telemetry_seek 
ON telemetry_logs (bike_id, logged_at DESC, log_id DESC);

--    Makes "Heatmap" queries fast
CREATE INDEX idx_telemetry_geo 
ON telemetry_logs USING GIST (location);

-- 6. INSERT TEST DATA (Seed)
--    Creates a test bike so your API tests work immediately.
INSERT INTO bikes (bike_id, last_seen_at, metadata) 
VALUES (
    'TEST_BIKE_001', 
    NOW(), 
    '{"model": "Test Unit", "color": "Debug Gray"}'
)
ON CONFLICT (bike_id) DO NOTHING;
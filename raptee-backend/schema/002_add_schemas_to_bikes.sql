-- Add schemas column to bikes table
-- This stores the mapping of log_type -> [column_names]
-- e.g. {"API_LATENCY": ["url", "latency", "status"]}

ALTER TABLE bikes 
ADD COLUMN IF NOT EXISTS schemas JSONB DEFAULT '{}'::jsonb;

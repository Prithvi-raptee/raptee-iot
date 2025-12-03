-- 1. Drop the existing foreign key constraint
-- Note: We assume the default name 'telemetry_logs_bike_id_fkey'. 
-- If it has a different name, this might fail, but for a fresh setup it should be standard.
ALTER TABLE telemetry_logs
DROP CONSTRAINT IF EXISTS telemetry_logs_bike_id_fkey;

-- 2. Add the new foreign key constraint with ON DELETE CASCADE
ALTER TABLE telemetry_logs
ADD CONSTRAINT telemetry_logs_bike_id_fkey
FOREIGN KEY (bike_id)
REFERENCES bikes(bike_id)
ON DELETE CASCADE;

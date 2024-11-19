-- Human Tasks:
-- 1. Verify that V1__init.sql migration has been executed successfully
-- 2. Ensure database connection is properly configured for development environment
-- 3. Confirm H2 database is running in a mode that supports TEXT and JSON data types

-- Addresses requirement: Sample Messages
-- Location: Technical Specification/SampleController/GET and POST Endpoints
-- Inserts initial message records for testing message endpoints and validations

-- Insert sample messages with valid content matching @NotBlank constraint
INSERT INTO messages (value, created_at) VALUES
    ('Spring boot says hello from a Docker container', CURRENT_TIMESTAMP),
    ('Welcome to Spring Boot Actuator Sample', CURRENT_TIMESTAMP),
    ('Sample message for testing validation', CURRENT_TIMESTAMP);

-- Addresses requirement: Health Status Data
-- Location: Technical Specification/Actuator Configuration
-- Inserts baseline health status records for testing actuator endpoints

-- Insert initial health status records for testing Actuator health indicators
INSERT INTO health_status (component, status, details, last_checked) VALUES
    ('helloHealthIndicator', 'UP', '{"hello":"world"}', CURRENT_TIMESTAMP),
    ('exampleHealthIndicator', 'UP', '{"counter":42}', CURRENT_TIMESTAMP);

-- Verify data insertion with count checks
-- Messages table should have exactly 3 records
ASSERT (SELECT COUNT(*) FROM messages) = 3 AS 'Expected 3 message records';

-- Health status table should have exactly 2 records
ASSERT (SELECT COUNT(*) FROM health_status) = 2 AS 'Expected 2 health status records';

-- Verify message content constraints
ASSERT NOT EXISTS (
    SELECT 1 FROM messages WHERE value IS NULL OR TRIM(value) = ''
) AS 'All messages must comply with @NotBlank constraint';

-- Verify health status data integrity
ASSERT NOT EXISTS (
    SELECT 1 FROM health_status 
    WHERE component IS NULL 
    OR status NOT IN ('UP', 'DOWN')
    OR details IS NULL
) AS 'Health status records must have valid component, status, and details';

-- Add execution metadata
COMMENT ON TABLE messages IS 'Sample data added by V2 migration for testing message endpoints';
COMMENT ON TABLE health_status IS 'Initial health status records added by V2 migration for Actuator testing';
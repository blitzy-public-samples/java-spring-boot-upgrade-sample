-- Human Tasks:
-- 1. Ensure H2 database is properly configured in application.properties/yaml
-- 2. Verify database user has sufficient privileges for table creation and index management
-- 3. Confirm Flyway migration settings are properly configured in application properties

-- Addresses requirement: Message Storage
-- Location: Technical Specification/SampleController/POST Endpoint
-- Creates messages table with validation constraints matching the Message entity model

-- Drop existing tables if they exist to ensure clean initialization
DROP TABLE IF EXISTS messages;
DROP TABLE IF EXISTS health_status;

-- Create messages table aligned with Message.java entity
-- Implements NOT NULL constraint to match @NotBlank validation
CREATE TABLE messages (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    value VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index on created_at for optimizing time-based queries
CREATE INDEX idx_messages_created_at ON messages(created_at);

-- Addresses requirement: Actuator Support
-- Location: Technical Specification/Actuator Configuration
-- Creates health_status table for storing component health check data

CREATE TABLE health_status (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    component VARCHAR(100) NOT NULL,
    status VARCHAR(20) NOT NULL,
    details TEXT,
    last_checked TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index on component for optimizing health status lookups
CREATE INDEX idx_health_component ON health_status(component);

-- Grant minimum required permissions for application operation
-- Note: Using H2 syntax for compatibility
GRANT SELECT, INSERT, UPDATE, DELETE ON messages TO PUBLIC;
GRANT SELECT, INSERT, UPDATE, DELETE ON health_status TO PUBLIC;

-- Add comments to tables for documentation
COMMENT ON TABLE messages IS 'Stores message entities with validation constraints matching Message.java model';
COMMENT ON TABLE health_status IS 'Stores Spring Boot Actuator health monitoring data';

-- Add column comments for clarity
COMMENT ON COLUMN messages.id IS 'Unique identifier for each message record';
COMMENT ON COLUMN messages.value IS 'Message content with NotBlank constraint';
COMMENT ON COLUMN messages.created_at IS 'Automatic timestamp for message creation tracking';

COMMENT ON COLUMN health_status.id IS 'Unique identifier for health status entry';
COMMENT ON COLUMN health_status.component IS 'Name of the health check component';
COMMENT ON COLUMN health_status.status IS 'Health status value (UP/DOWN)';
COMMENT ON COLUMN health_status.details IS 'JSON details of health check including custom data';
COMMENT ON COLUMN health_status.last_checked IS 'Timestamp of last health check execution';
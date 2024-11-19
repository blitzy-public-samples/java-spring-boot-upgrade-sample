package sample.actuator.dto;

import com.fasterxml.jackson.annotation.JsonProperty; // version: 2.15.0

import java.util.Map;
import java.util.Objects;

/**
 * Data Transfer Object (DTO) representing the health endpoint response structure from Spring Boot Actuator.
 * 
 * Requirements addressed:
 * - Health Monitoring: Provides structured response format for health endpoint data with status and details
 * - Health Details Exposure: Supports detailed health information exposure as configured in management.endpoint.health.show-details
 */
public class HealthResponse {
    
    @JsonProperty("status")
    private String status;
    
    @JsonProperty("details")
    private Map<String, Object> details;
    
    /**
     * Default constructor for JSON deserialization
     */
    public HealthResponse() {
        // Initialize empty instance
    }
    
    /**
     * Gets the health status value indicating the overall system health
     * 
     * @return The health status (UP, DOWN, OUT_OF_SERVICE, UNKNOWN)
     */
    public String getStatus() {
        return status;
    }
    
    /**
     * Sets the health status value
     * 
     * @param status The health status to set
     * @throws IllegalArgumentException if status is null
     */
    public void setStatus(String status) {
        // Validate status is not null
        Objects.requireNonNull(status, "Health status cannot be null");
        this.status = status;
    }
    
    /**
     * Gets the health check details map containing component-specific health information
     * 
     * @return Map containing detailed health check information for each component
     */
    public Map<String, Object> getDetails() {
        return details;
    }
    
    /**
     * Sets the health check details map
     * 
     * @param details Map containing detailed health check information
     */
    public void setDetails(Map<String, Object> details) {
        this.details = details;
    }
}
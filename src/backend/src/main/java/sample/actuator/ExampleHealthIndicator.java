package sample.actuator;

// Spring Boot Actuator Health - v3.0.0
import org.springframework.boot.actuate.health.Health;
import org.springframework.boot.actuate.health.HealthIndicator;
// Spring Framework Stereotype - v6.0.0
import org.springframework.stereotype.Component;

/**
 * Custom health indicator that provides system health status with a counter metric.
 * Implements Spring Boot 3 Actuator's health monitoring capabilities.
 * 
 * Requirements addressed:
 * - Spring Boot 3 Migration: Implementation of health indicator compatible with 
 *   Spring Boot 3 Actuator framework for system monitoring and health checks
 */
@Component
public class ExampleHealthIndicator implements HealthIndicator {

    /**
     * Default constructor used by Spring for component instantiation.
     */
    public ExampleHealthIndicator() {
        // No initialization needed for this basic health indicator
    }

    /**
     * Implements the health check logic returning system status with counter metric.
     * This method is called by Spring Boot Actuator to determine the health status
     * of this component.
     *
     * @return Health object indicating UP state with a counter metric
     */
    @Override
    public Health health() {
        return Health.up()
                .withDetail("counter", 42)
                .build();
    }
}
package sample.actuator;

// Spring Boot 3.0.0
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.boot.actuate.health.Health;
import org.springframework.boot.actuate.health.HealthIndicator;
import org.springframework.context.annotation.Bean;

/**
 * Main Spring Boot 3 application class that bootstraps the application and configures health indicators.
 * 
 * Human Tasks:
 * 1. Verify Spring Boot 3.0.0 dependencies in pom.xml or build.gradle
 * 2. Ensure actuator endpoints are properly configured in application.properties/yml
 * 3. Configure appropriate security settings for actuator endpoints in production
 * 4. Verify health endpoint is accessible at /actuator/health
 *
 * Requirements Addressed:
 * - Spring Boot 3 Migration: Main application class upgraded to Spring Boot 3 
 *   while preserving existing functionality
 * - Health Endpoint Configuration: Implements custom health indicator for 
 *   application monitoring through actuator endpoints
 */
@SpringBootApplication
@EnableConfigurationProperties(ServiceProperties.class)
public class SampleActuatorApplication {

    /**
     * Application entry point that bootstraps the Spring Boot application.
     * Enables component scanning, auto-configuration, and embedded server.
     *
     * @param args command line arguments passed to the application
     */
    public static void main(String[] args) {
        SpringApplication.run(SampleActuatorApplication.class, args);
    }

    /**
     * Configures a custom health indicator that contributes to the application's health status.
     * This indicator adds a "hello" detail to the health endpoint response and always returns UP status.
     * Accessible via the /actuator/health endpoint.
     *
     * Requirements Addressed:
     * - Health Endpoint Configuration: Provides custom health indicator implementation
     *   for application monitoring through actuator endpoints
     *
     * @return HealthIndicator bean that reports application health status
     */
    @Bean
    public HealthIndicator helloHealthIndicator() {
        return () -> Health.up()
                         .withDetail("hello", "world")
                         .build();
    }
}
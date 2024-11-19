package sample.actuator;

// Spring Boot 3.0.0
import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * Configuration properties for service-specific settings.
 * 
 * Human Tasks:
 * 1. Ensure application.properties/yml has correct prefix: service.*
 * 2. Enable @ConfigurationPropertiesScan or @EnableConfigurationProperties in your configuration
 *
 * Requirements Addressed:
 * - Spring Boot 3 Configuration Properties: Implements type-safe configuration binding 
 *   with validation of unknown fields while preserving existing externalized configuration functionality
 */
@ConfigurationProperties(prefix = "service", ignoreUnknownFields = false)
public class ServiceProperties {

    /**
     * The name of the service configured via external configuration.
     * Defaults to "World" if not specified.
     */
    private String name;

    /**
     * Default constructor that initializes the name property with default value.
     */
    public ServiceProperties() {
        this.name = "World";
    }

    /**
     * Gets the configured service name.
     *
     * @return the current value of the service name property
     */
    public String getName() {
        return this.name;
    }

    /**
     * Sets the service name in configuration.
     *
     * @param name the name to set, must not be null
     * @throws IllegalArgumentException if name is null
     */
    public void setName(String name) {
        if (name == null) {
            throw new IllegalArgumentException("Name must not be null");
        }
        this.name = name;
    }
}
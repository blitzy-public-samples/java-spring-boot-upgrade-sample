package sample.actuator.config;

// Spring Framework Context Annotations - v6.0.0
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

// Spring Boot Autoconfigure Conditions - v3.0.0
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;

// Spring Boot Actuator Autoconfigure - v3.0.0
import org.springframework.boot.actuate.autoconfigure.endpoint.EndpointAutoConfiguration;

// Internal components
import sample.actuator.ExampleHealthIndicator;
import sample.actuator.ExampleInfoContributor;

/**
 * Configuration class for customizing Spring Boot Actuator endpoints and indicators.
 * Provides conditional bean definitions for health indicators and info contributors
 * in a Spring Boot 3.x environment.
 *
 * Human Tasks:
 * 1. Verify that Spring Boot Actuator dependency is included in the project:
 *    - org.springframework.boot:spring-boot-starter-actuator:3.x.x
 * 2. Configure actuator endpoints in application.properties/yaml:
 *    - management.endpoints.web.exposure.include=health,info
 *    - management.endpoint.health.show-details=always
 * 3. Review security settings to ensure actuator endpoints are properly secured
 *
 * Requirements addressed:
 * - Spring Boot 3 Migration: Configures actuator endpoints and health indicators
 *   for Spring Boot 3 compatibility with proper component registration and
 *   conditional creation
 */
@Configuration
public class ActuatorConfig extends EndpointAutoConfiguration {

    /**
     * Default constructor used by Spring for configuration class instantiation.
     */
    public ActuatorConfig() {
        // Initialize configuration class with parent constructor
        super();
    }

    /**
     * Configures and registers the example health indicator if not already defined.
     * This health indicator will be automatically picked up by Spring Boot Actuator
     * and included in the /actuator/health endpoint response.
     *
     * @return Configured health indicator instance that reports UP status with counter metric
     */
    @Bean
    @ConditionalOnMissingBean
    public ExampleHealthIndicator healthIndicator() {
        return new ExampleHealthIndicator();
    }

    /**
     * Configures and registers the example info contributor if not already defined.
     * This info contributor will be automatically picked up by Spring Boot Actuator
     * and included in the /actuator/info endpoint response.
     *
     * @return Configured info contributor instance that adds example data to info endpoint
     */
    @Bean
    @ConditionalOnMissingBean
    public ExampleInfoContributor infoContributor() {
        return new ExampleInfoContributor();
    }
}
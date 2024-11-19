package sample.actuator;

import java.util.Collections; // java.util version 6.x
import org.springframework.boot.actuate.info.Info; // spring-boot-actuator version 3.0.0
import org.springframework.boot.actuate.info.InfoContributor; // spring-boot-actuator version 3.0.0
import org.springframework.stereotype.Component; // spring-framework version 6.x
import sample.actuator.dto.InfoResponse;

/**
 * Implementation of Spring Boot Actuator's InfoContributor interface that contributes
 * custom information to the /actuator/info endpoint.
 *
 * Human Tasks:
 * 1. Ensure Spring Boot Actuator is properly configured in application.properties/yaml:
 *    - management.endpoints.web.exposure.include=info
 *    - management.info.env.enabled=true
 * 2. Verify that the /actuator/info endpoint is accessible and properly secured
 *    according to your security requirements
 *
 * Requirements Addressed:
 * - Custom Info Endpoint Data: This implementation contributes custom key-value information
 *   to Spring Boot Actuator's info endpoint, allowing the application to expose additional
 *   metadata through the standard actuator interface
 */
@Component
public class ExampleInfoContributor implements InfoContributor {

    /**
     * Default constructor for ExampleInfoContributor.
     * Spring will automatically instantiate this component during component scanning.
     */
    public ExampleInfoContributor() {
        // Default constructor with no additional initialization needed
    }

    /**
     * Contributes custom information to the Spring Boot Actuator info endpoint.
     * This method is called automatically by the Spring Boot Actuator framework
     * when the /actuator/info endpoint is accessed.
     *
     * The custom information is added to the info endpoint response under the
     * 'example' key, demonstrating how to extend the default info endpoint
     * with application-specific data.
     *
     * @param builder the Info.Builder instance provided by Spring Boot Actuator
     *                to construct the info endpoint response
     */
    @Override
    public void contribute(Info.Builder builder) {
        // Create an InfoResponse instance to demonstrate usage of the DTO
        InfoResponse infoResponse = new InfoResponse(
            Collections.singletonMap("customKey", "This is an example value")
        );

        // Add the custom information to the info endpoint builder
        // The data will be accessible under the 'example' key in the info endpoint response
        builder.withDetail("example", infoResponse.getInfoData());
    }
}
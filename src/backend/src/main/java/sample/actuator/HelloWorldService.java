package sample.actuator;

// Spring Framework 6.0.0
import org.springframework.stereotype.Service;

/**
 * Service class that provides hello message functionality for the Spring Boot application 
 * running in a Docker container.
 * 
 * Requirements addressed:
 * - Service Layer Implementation: Implements service layer functionality for hello message 
 *   feature using Spring Boot 3 and Java 6.x
 */
@Service
public class HelloWorldService {
    
    /**
     * Default no-args constructor used by Spring for dependency injection
     */
    public HelloWorldService() {
        // Initialize the service instance
    }

    /**
     * Returns a hello message indicating the application is running in a Docker container.
     * This method is called by controllers to get the greeting message.
     *
     * @return A greeting message indicating Spring Boot is running in Docker
     */
    public String getHelloMessage() {
        return "Spring boot says hello from a Docker container";
    }
}
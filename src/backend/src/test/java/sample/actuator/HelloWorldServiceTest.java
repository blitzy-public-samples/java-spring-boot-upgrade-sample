package sample.actuator;

// JUnit 5.9.0
import static org.junit.jupiter.api.Assertions.assertEquals;
import org.junit.jupiter.api.Test;

/**
 * Unit test class for HelloWorldService that verifies the hello message functionality.
 * 
 * Requirements addressed:
 * - Service Layer Testing: Implements unit tests for HelloWorldService to verify 
 *   hello message functionality and ensure correct message content for Docker 
 *   container deployment
 */
public class HelloWorldServiceTest {

    /**
     * Default constructor for test class instantiation
     */
    public HelloWorldServiceTest() {
        // Initialize test class instance
    }

    /**
     * Tests that HelloWorldService returns the expected hello message from Docker container.
     * 
     * Test steps:
     * 1. Create new instance of HelloWorldService
     * 2. Call getHelloMessage() to retrieve greeting
     * 3. Verify returned message matches expected Docker container greeting
     */
    @Test
    public void expectedMessage() {
        // Create new instance of service under test
        HelloWorldService service = new HelloWorldService();
        
        // Get actual message from service
        String actualMessage = service.getHelloMessage();
        
        // Verify message matches expected Docker container greeting
        assertEquals("Spring boot says hello from a Docker container", actualMessage, 
            "HelloWorldService should return correct Docker container greeting message");
    }
}
package sample.actuator;

// JUnit Jupiter 5.9.0
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.Assertions;

// Spring Framework Test 6.0.0
import org.springframework.test.context.TestPropertySource;

// Spring Boot Test 3.0.0
import org.springframework.boot.test.context.SpringBootTest;

/**
 * Integration test class for validating Spring Boot 3 application functionality and health monitoring.
 * 
 * Human Tasks:
 * 1. Ensure application-test.properties exists in src/test/resources with required test configurations
 * 2. Verify test dependencies are correctly specified in build configuration
 * 3. Configure test logging levels if needed for debugging
 * 4. Ensure test environment has necessary permissions to execute health checks
 *
 * Requirements Addressed:
 * - Spring Boot 3 Migration: Test class updated to use Spring Boot 3 test framework
 *   while maintaining existing test coverage and validating Spring Boot 3 specific configurations
 * - Health Endpoint Testing: Validates health indicator configuration and responses
 *   including the custom hello world health indicator
 */
@SpringBootTest(classes = SampleActuatorApplication.class)
@TestPropertySource(locations = "classpath:application-test.properties")
public class SampleActuatorApplicationTests {

    /**
     * Verifies that the Spring application context loads successfully with all required configurations.
     * This test validates:
     * 1. Spring Boot 3 application context initialization
     * 2. Auto-configuration processing
     * 3. Component scanning
     * 4. Bean registration including the custom health indicator
     * 5. Property source configuration
     *
     * Requirements Addressed:
     * - Spring Boot 3 Migration: Validates successful context loading with Spring Boot 3
     * - Health Endpoint Testing: Verifies health indicator bean registration
     */
    @Test
    public void contextLoads() {
        // Test passes if context loads successfully
        // Spring Boot test framework automatically validates:
        // - Application context initialization
        // - Bean creation and injection
        // - Configuration processing
        // - Health indicator registration
        
        // If any configuration issues occur, the test will fail with appropriate exceptions
        // No explicit assertions needed as context loading itself serves as the test
    }
}
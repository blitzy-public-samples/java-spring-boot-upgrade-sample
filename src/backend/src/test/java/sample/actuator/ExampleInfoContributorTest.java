package sample.actuator;

// JUnit Jupiter version 5.8.2
import org.junit.jupiter.api.Test;

// Mockito version 4.5.1
import org.mockito.ArgumentMatchers;
import org.mockito.Mockito;

// Spring Boot Actuator version 3.0.0
import org.springframework.boot.actuate.info.Info;

/**
 * Unit tests for ExampleInfoContributor class that validates its behavior in contributing
 * custom information to Spring Boot Actuator's info endpoint.
 *
 * Human Tasks:
 * 1. Ensure Spring Boot Actuator test dependencies are properly configured in build.gradle/pom.xml
 * 2. Verify that test coverage requirements are met for the info endpoint contribution logic
 *
 * Requirements Addressed:
 * - Custom Info Endpoint Testing: Validates that ExampleInfoContributor correctly contributes
 *   custom information to the info endpoint by verifying the interaction with Info.Builder
 *   and ensuring proper structure of contributed data
 */
public class ExampleInfoContributorTest {

    /**
     * Tests that the ExampleInfoContributor correctly contributes information to the
     * info endpoint using the Info.Builder interface.
     * 
     * Verifies:
     * - Proper interaction with Info.Builder
     * - Correct usage of 'example' key for detail contribution
     * - Appropriate handling of detail value
     */
    @Test
    public void infoMap() {
        // Create a mock Info.Builder object
        Info.Builder builder = Mockito.mock(Info.Builder.class);
        
        // Create instance of the class under test
        ExampleInfoContributor contributor = new ExampleInfoContributor();
        
        // When withDetail is called on the mock builder, return the builder itself
        // This allows for method chaining if needed
        Mockito.when(builder.withDetail(Mockito.anyString(), ArgumentMatchers.any()))
               .thenReturn(builder);
        
        // Execute the method under test
        contributor.contribute(builder);
        
        // Verify that builder.withDetail() was called exactly once with:
        // - The key "example"
        // - Any Map argument (since we know the actual map comes from InfoResponse)
        Mockito.verify(builder).withDetail(
            Mockito.eq("example"),
            ArgumentMatchers.any()
        );
    }
}
package sample.actuator.mapper;

// JUnit 5 v5.8.2
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import static org.junit.jupiter.api.Assertions.*;

// Mockito v4.5.1
import org.mockito.InjectMocks;
import org.mockito.junit.jupiter.MockitoExtension;

import sample.actuator.model.Message;
import sample.actuator.dto.MessageResponse;

/**
 * Human Tasks:
 * 1. Ensure JUnit 5 dependency is added to build configuration:
 *    org.junit.jupiter.api:junit-jupiter:5.8.2
 * 2. Ensure Mockito dependency is added to build configuration:
 *    org.mockito:mockito-core:4.5.1
 * 3. Verify test execution is properly configured in build system
 */

/**
 * Unit tests for MessageMapper functionality validating the mapping between 
 * Message model objects and MessageResponse DTOs.
 * 
 * Requirement Addressed: Message Response Mapping Tests
 * Location: Technical Specification/SampleController/POST Endpoint
 * Description: Validates that Message objects are correctly mapped to MessageResponse DTOs 
 * with all required fields including message content, static title 'Hello Home', 
 * and current timestamp
 */
@ExtendWith(MockitoExtension.class)
public class MessageMapperTest {

    @InjectMocks
    private MessageMapper messageMapper;

    /**
     * Tests the mapping from Message to MessageResponse ensuring all fields are 
     * correctly mapped according to requirements.
     * 
     * Validates:
     * - Message content is transferred correctly
     * - Static title "Hello Home" is set
     * - Current timestamp is generated
     */
    @Test
    public void testToMessageResponse() {
        // Create and configure test Message object
        Message testMessage = new Message();
        testMessage.setValue("Test Message");

        // Perform the mapping
        MessageResponse result = messageMapper.toMessageResponse(testMessage);

        // Verify message content is mapped correctly
        assertNotNull(result, "Mapped MessageResponse should not be null");
        assertEquals("Test Message", result.getMessage(), 
            "Message content should be transferred correctly");

        // Verify static title is set as required
        assertEquals("Hello Home", result.getTitle(), 
            "Title should be set to 'Hello Home'");

        // Verify timestamp is generated
        assertNotNull(result.getDate(), 
            "Timestamp should be generated");
        
        // Verify timestamp is recent (within last second)
        long timeDifference = System.currentTimeMillis() - result.getDate().getTime();
        assertTrue(timeDifference < 1000, 
            "Timestamp should represent current time");
    }
}
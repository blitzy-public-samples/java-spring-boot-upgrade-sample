package sample.actuator.repository;

// JUnit Jupiter v5.9.0
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.Assertions;

// Spring Boot Test v3.0.0
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
// Spring Framework v6.0.0
import org.springframework.beans.factory.annotation.Autowired;

import sample.actuator.model.Message;
import java.util.List;

/**
 * Unit tests for MessageRepository to validate JPA operations and custom queries.
 * 
 * Addresses requirement: Message Persistence Testing
 * Location: Technical Specification/Testing/Repository Tests
 * - Validates data access operations for Message entities
 * - Tests save, findByValue and findLatestMessages operations
 * - Uses Spring Data JPA test slice with in-memory database
 */
@DataJpaTest
public class MessageRepositoryTest {

    @Autowired
    private MessageRepository messageRepository;

    /**
     * Tests the findByValue repository method to verify message retrieval by value content.
     * 
     * Addresses requirement: Message Persistence Testing
     * - Validates findByValue query returns correct message based on value content
     */
    @Test
    public void testFindByValue() {
        // Create and save test message
        Message message = new Message();
        message.setValue("test message");
        messageRepository.save(message);

        // Query for saved message
        List<Message> foundMessages = messageRepository.findByValue("test message");
        
        // Verify results
        Assertions.assertFalse(foundMessages.isEmpty(), "Should find message with matching value");
        Assertions.assertEquals("test message", foundMessages.get(0).getValue(), 
            "Retrieved message should have matching value");
    }

    /**
     * Tests the findLatestMessages repository method to verify pagination and ordering.
     * 
     * Addresses requirement: Message Persistence Testing
     * - Validates findLatestMessages returns correct number of messages
     * - Verifies messages are returned in descending order
     */
    @Test
    public void testFindLatestMessages() {
        // Create and save multiple test messages
        Message message1 = new Message();
        message1.setValue("first message");
        messageRepository.save(message1);

        Message message2 = new Message();
        message2.setValue("second message");
        messageRepository.save(message2);

        Message message3 = new Message();
        message3.setValue("third message");
        messageRepository.save(message3);

        // Query for latest messages with limit
        int limit = 2;
        List<Message> latestMessages = messageRepository.findLatestMessages(limit);

        // Verify results
        Assertions.assertEquals(limit, latestMessages.size(), 
            "Should return exactly " + limit + " messages");
        Assertions.assertEquals("third message", latestMessages.get(0).getValue(),
            "First message should be the latest one");
        Assertions.assertEquals("second message", latestMessages.get(1).getValue(),
            "Second message should be the second latest");
    }
}
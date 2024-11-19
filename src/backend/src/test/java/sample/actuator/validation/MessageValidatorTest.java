package sample.actuator.validation;

// JUnit 5 v5.8.2
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Assertions;

// Spring Framework v6.0.0
import org.springframework.validation.Errors;
import org.springframework.validation.BeanPropertyBindingResult;

import sample.actuator.model.Message;

/**
 * Unit tests for MessageValidator to verify message validation logic.
 * 
 * Addresses requirement: Message Validation Testing
 * Location: Technical Specification/SampleController/POST Endpoint
 * - Verifies that message validation correctly enforces non-empty values
 * - Tests proper class support through comprehensive unit tests
 */
public class MessageValidatorTest {

    private MessageValidator validator;
    private Message message;
    private Errors errors;

    /**
     * Setup method run before each test to initialize test objects.
     * Creates fresh instances of validator, message, and errors objects
     * to ensure clean state for each test.
     */
    @BeforeEach
    public void setup() {
        validator = new MessageValidator();
        message = new Message();
        errors = new BeanPropertyBindingResult(message, "message");
    }

    /**
     * Test that validator correctly supports Message class.
     * Verifies the supports() method returns true for Message.class.
     */
    @Test
    public void testSupportsMessage() {
        boolean result = validator.supports(Message.class);
        Assertions.assertTrue(result, "MessageValidator should support Message class");
    }

    /**
     * Test that validator correctly rejects other classes.
     * Verifies the supports() method returns false for non-Message classes.
     */
    @Test
    public void testSupportsOtherClass() {
        boolean result = validator.supports(Object.class);
        Assertions.assertFalse(result, "MessageValidator should not support Object class");
    }

    /**
     * Test validation of empty message value.
     * Verifies that the validator correctly identifies and reports empty message values.
     */
    @Test
    public void testValidateEmptyMessage() {
        message.setValue("");
        validator.validate(message, errors);
        
        Assertions.assertTrue(errors.hasErrors(), "Validation should fail for empty message");
        Assertions.assertEquals(
            "Message.value.empty",
            errors.getFieldError("value").getCode(),
            "Error code should match expected value"
        );
        Assertions.assertEquals(
            "Message value cannot be empty",
            errors.getFieldError("value").getDefaultMessage(),
            "Error message should match expected value"
        );
    }

    /**
     * Test validation of valid message value.
     * Verifies that the validator accepts non-empty message values.
     */
    @Test
    public void testValidateValidMessage() {
        message.setValue("test message");
        validator.validate(message, errors);
        
        Assertions.assertFalse(errors.hasErrors(), "Validation should pass for non-empty message");
    }
}
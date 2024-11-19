package sample.actuator.validation;

// Spring Framework v6.0.0
import org.springframework.stereotype.Component;
import org.springframework.validation.Errors;
import org.springframework.validation.Validator;
import org.springframework.util.StringUtils;

import sample.actuator.model.Message;

/**
 * Validator component that implements Spring's Validator interface to validate Message objects.
 * Provides programmatic validation in addition to annotation-based validation.
 * 
 * Addresses requirement: Message Validation
 * Location: Technical Specification/SampleController/POST Endpoint
 * - Implements validation logic to ensure message values are not blank before processing
 * - Complements the @NotBlank constraint on the Message model
 */
@Component
public class MessageValidator implements Validator {

    /**
     * Default constructor for MessageValidator.
     * No additional initialization required as validator is stateless.
     */
    public MessageValidator() {
        // No initialization needed - validator is stateless
    }

    /**
     * Determines if this validator can validate instances of the given class.
     * 
     * @param clazz the Class to check for validation support
     * @return true if this validator supports the Message class, false otherwise
     */
    @Override
    public boolean supports(Class<?> clazz) {
        return Message.class.equals(clazz);
    }

    /**
     * Validates the given Message object, checking for empty or blank message values.
     * This validation complements the @NotBlank annotation on the Message model by providing
     * programmatic validation capabilities.
     * 
     * @param target the Message object to validate
     * @param errors the Errors object to record validation failures
     */
    @Override
    public void validate(Object target, Errors errors) {
        Message message = (Message) target;
        
        // Get message value and validate it's not empty/blank
        String value = message.getValue();
        if (!StringUtils.hasText(value)) {
            errors.rejectValue(
                "value",
                "Message.value.empty",
                "Message value cannot be empty"
            );
        }
    }
}
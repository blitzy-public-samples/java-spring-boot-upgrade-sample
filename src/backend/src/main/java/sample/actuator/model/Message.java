package sample.actuator.model;

// javax.validation.constraints v6.0.0
import javax.validation.constraints.NotBlank;

// lombok v1.18.22
import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;

/**
 * Model class representing a message with validation constraints for use in REST endpoints.
 * 
 * Addresses requirement: Message Validation
 * Location: Technical Specification/SampleController/POST Endpoint
 * - Implements message model with validation constraints ensuring message value is not blank
 * - Used by the POST endpoint in SampleController for handling message submissions
 */
@Getter
@Setter
@NoArgsConstructor
public class Message {
    
    /**
     * The message value that must not be blank when set.
     * Validated using @NotBlank constraint to ensure non-empty meaningful messages.
     */
    @NotBlank(message = "Message value cannot be blank")
    private String value;
}
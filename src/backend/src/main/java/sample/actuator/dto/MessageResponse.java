package sample.actuator.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import java.util.Date;

/**
 * Human Tasks:
 * 1. Ensure Lombok dependency is added to the project's build.gradle/pom.xml:
 *    org.projectlombok:lombok:1.18.22
 * 2. Verify Lombok annotation processor is enabled in IDE
 */

/**
 * Data Transfer Object (DTO) representing the response format for message-related endpoints.
 * 
 * Requirement Addressed: Message Response Format
 * Location: Technical Specification/SampleController/POST Endpoint
 * Description: Implements response format containing message, title and date fields
 * matching the LinkedHashMap structure used in the controller
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MessageResponse {
    
    /**
     * The message content of the response
     */
    private String message;
    
    /**
     * The title of the message
     */
    private String title;
    
    /**
     * Timestamp indicating when the message was created/processed
     */
    private Date date;
}
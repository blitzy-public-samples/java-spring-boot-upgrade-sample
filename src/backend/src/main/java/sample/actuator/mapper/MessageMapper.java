package sample.actuator.mapper;

// MapStruct v1.5.3.Final
import org.mapstruct.Mapper;

import java.util.Date;
import sample.actuator.model.Message;
import sample.actuator.dto.MessageResponse;

/**
 * Human Tasks:
 * 1. Ensure MapStruct dependency is added to the project's build configuration:
 *    org.mapstruct:mapstruct:1.5.3.Final
 * 2. Add MapStruct annotation processor to build configuration:
 *    org.mapstruct:mapstruct-processor:1.5.3.Final
 * 3. Verify annotation processing is enabled in IDE
 */

/**
 * MapStruct mapper interface for converting between Message and MessageResponse objects.
 * 
 * Requirement Addressed: Message Response Mapping
 * Location: Technical Specification/SampleController/POST Endpoint
 * Description: Maps Message model objects to MessageResponse DTOs with required fields 
 * for the response format, ensuring proper transformation of validated message content 
 * along with static title and current timestamp
 */
@Mapper(componentModel = "spring")
public interface MessageMapper {

    /**
     * Maps a validated Message object to a MessageResponse DTO with required fields.
     * The mapping:
     * - Sets message content from Message.value
     * - Sets static title "Hello Home"
     * - Sets current timestamp
     *
     * @param message The validated Message object to map
     * @return MessageResponse containing mapped data with required fields
     */
    default MessageResponse toMessageResponse(Message message) {
        if (message == null) {
            return null;
        }
        
        return MessageResponse.builder()
                .message(message.getValue())
                .title("Hello Home")
                .date(new Date())
                .build();
    }
}
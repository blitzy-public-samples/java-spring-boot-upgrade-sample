package sample.actuator;

// Spring Framework 6.0.0
import org.springframework.stereotype.Controller;
import org.springframework.context.annotation.Description;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.validation.annotation.Validated;

// Java Validation API 6.0.0
import javax.validation.constraints.NotBlank;

import java.util.Date;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * REST controller that handles HTTP requests for hello messages and demonstrates 
 * Spring Boot features including validation and error handling.
 * 
 * Requirements addressed:
 * - REST API Implementation: Implements REST endpoints for hello message functionality 
 *   using Spring Boot 3 and Java 6.x
 * - Message Validation: Implements message validation using Spring validation framework
 */
@Controller
@Description("A controller for handling requests for hello messages")
@RequestMapping("/")
@Validated
public class SampleController {

    private final HelloWorldService helloWorldService;

    /**
     * Constructs a new SampleController with required dependencies.
     * 
     * @param helloWorldService Service component for generating hello messages
     */
    public SampleController(HelloWorldService helloWorldService) {
        this.helloWorldService = helloWorldService;
    }

    /**
     * Handles GET requests to the root endpoint, returning a hello message from the service.
     * 
     * @return Map containing the hello message in JSON format
     */
    @GetMapping(value = "/", produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public Map<String, String> hello() {
        String message = helloWorldService.getHelloMessage();
        Map<String, String> response = new HashMap<>();
        response.put("message", message);
        return response;
    }

    /**
     * Handles POST requests to the root endpoint with message validation.
     * 
     * @param message The message object containing the value to validate
     * @return Map containing the validated message and additional metadata
     */
    @PostMapping(value = "/", produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public Map<String, Object> olleh(Message message) {
        Map<String, Object> response = new LinkedHashMap<>();
        response.put("message", message.getValue());
        response.put("title", "Hello Home");
        response.put("date", new Date());
        return response;
    }

    /**
     * Endpoint that demonstrates Spring Boot error handling by throwing an exception.
     * 
     * @throws IllegalArgumentException Always throws this exception for demonstration
     */
    @RequestMapping("/foo")
    @ResponseBody
    public String foo() {
        throw new IllegalArgumentException("Server error");
    }

    /**
     * Static inner class representing a message with validation constraints.
     */
    public static class Message {
        @NotBlank(message = "Message value cannot be blank")
        private String value;

        /**
         * Gets the message value.
         * 
         * @return The message value
         */
        public String getValue() {
            return value;
        }

        /**
         * Sets the message value with validation.
         * 
         * @param value The message value to set
         */
        public void setValue(String value) {
            this.value = value;
        }
    }
}
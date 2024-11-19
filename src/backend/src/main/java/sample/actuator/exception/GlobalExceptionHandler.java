package sample.actuator.exception;

// Spring Framework imports - version 6.0.0
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.MethodArgumentNotValidException;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Global exception handler for the Spring Boot 3 application that provides centralized
 * exception handling and consistent error responses across all controllers.
 * 
 * Human Tasks:
 * 1. Ensure logging configuration is properly set up in application.properties/yaml
 * 2. Review and adjust error messages for production use if needed
 * 3. Configure any environment-specific error handling behavior
 */
@ControllerAdvice
public class GlobalExceptionHandler {

    /**
     * Handles IllegalArgumentException for invalid input parameters.
     * Implements requirement: Error Handling - Consistent error response format
     *
     * @param ex The IllegalArgumentException instance
     * @return ResponseEntity containing error details with HTTP 400 status
     */
    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<Object> handleIllegalArgumentException(IllegalArgumentException ex) {
        Map<String, Object> errorResponse = new HashMap<>();
        errorResponse.put("timestamp", LocalDateTime.now().toString());
        errorResponse.put("status", HttpStatus.BAD_REQUEST.value());
        errorResponse.put("error", "Bad Request");
        errorResponse.put("message", ex.getMessage());
        errorResponse.put("errorType", "INVALID_ARGUMENT");

        return new ResponseEntity<>(errorResponse, HttpStatus.BAD_REQUEST);
    }

    /**
     * Handles validation exceptions from @Valid annotations on request bodies.
     * Implements requirement: Error Handling - Support for validation errors
     *
     * @param ex The MethodArgumentNotValidException instance
     * @return ResponseEntity containing validation error details with HTTP 400 status
     */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Object> handleValidationExceptions(MethodArgumentNotValidException ex) {
        Map<String, Object> errorResponse = new HashMap<>();
        
        // Extract and format validation errors
        Map<String, String> validationErrors = ex.getBindingResult()
            .getFieldErrors()
            .stream()
            .collect(Collectors.toMap(
                error -> error.getField(),
                error -> error.getDefaultMessage() != null ? error.getDefaultMessage() : "Invalid value",
                (error1, error2) -> error1
            ));

        errorResponse.put("timestamp", LocalDateTime.now().toString());
        errorResponse.put("status", HttpStatus.BAD_REQUEST.value());
        errorResponse.put("error", "Validation Failed");
        errorResponse.put("errorType", "VALIDATION_ERROR");
        errorResponse.put("errors", validationErrors);

        return new ResponseEntity<>(errorResponse, HttpStatus.BAD_REQUEST);
    }

    /**
     * Fallback handler for any unhandled exceptions in the application.
     * Implements requirement: Error Handling - General exception handling
     *
     * @param ex The Exception instance
     * @return ResponseEntity containing error details with HTTP 500 status
     */
    @ExceptionHandler(Exception.class)
    public ResponseEntity<Object> handleGenericException(Exception ex) {
        Map<String, Object> errorResponse = new HashMap<>();
        errorResponse.put("timestamp", LocalDateTime.now().toString());
        errorResponse.put("status", HttpStatus.INTERNAL_SERVER_ERROR.value());
        errorResponse.put("error", "Internal Server Error");
        errorResponse.put("message", "An unexpected error occurred");
        errorResponse.put("errorType", "INTERNAL_ERROR");
        
        // In a production environment, you might want to generate and include
        // an error reference number for tracking purposes
        
        // Log the full exception for debugging while keeping the response generic
        // Logger would be injected in a production setup
        ex.printStackTrace(); // Replace with proper logging in production

        return new ResponseEntity<>(errorResponse, HttpStatus.INTERNAL_SERVER_ERROR);
    }
}
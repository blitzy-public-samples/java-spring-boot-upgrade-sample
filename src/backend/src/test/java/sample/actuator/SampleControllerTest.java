package sample.actuator;

// Spring Test Framework 6.0.0
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

// Spring Framework 6.0.0
import org.springframework.http.MediaType;

// Jackson 2.15.0
import com.fasterxml.jackson.databind.ObjectMapper;

// JUnit Jupiter 5.9.3
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.extension.ExtendWith;

// Mockito 5.3.1
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import static org.mockito.Mockito.when;

/**
 * Unit tests for SampleController that verify REST endpoint behaviors.
 * 
 * Requirements addressed:
 * - REST API Testing: Implements comprehensive tests for REST endpoints including
 *   hello message functionality, message validation, and error handling
 */
@ExtendWith(MockitoExtension.class)
public class SampleControllerTest {

    private MockMvc mockMvc;
    private ObjectMapper objectMapper;

    @Mock
    private HelloWorldService helloWorldService;

    private SampleController sampleController;

    /*
    * Human Tasks:
    * 1. Ensure Spring Boot Test and Mockito dependencies are included in pom.xml
    * 2. Verify test execution environment has appropriate permissions
    * 3. Configure test logging level if needed for debugging
    */

    @BeforeEach
    void setUp() {
        objectMapper = new ObjectMapper();
        sampleController = new SampleController(helloWorldService);
        mockMvc = MockMvcBuilders.standaloneSetup(sampleController)
                                .build();
    }

    @Test
    void testHelloEndpoint() throws Exception {
        // Given
        String expectedMessage = "Spring boot says hello from a Docker container";
        when(helloWorldService.getHelloMessage()).thenReturn(expectedMessage);

        // When & Then
        mockMvc.perform(get("/")
                .accept(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.message").value(expectedMessage));
    }

    @Test
    void testOllehEndpoint() throws Exception {
        // Given
        SampleController.Message message = new SampleController.Message();
        message.setValue("Test message");

        // When & Then
        mockMvc.perform(post("/")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(message))
                .accept(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.message").value("Test message"))
                .andExpect(jsonPath("$.title").value("Hello Home"))
                .andExpect(jsonPath("$.date").exists());
    }

    @Test
    void testOllehEndpointValidation() throws Exception {
        // Given
        SampleController.Message message = new SampleController.Message();
        message.setValue(""); // Invalid blank message

        // When & Then
        mockMvc.perform(post("/")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(message))
                .accept(MediaType.APPLICATION_JSON))
                .andExpect(status().isBadRequest());
    }

    @Test
    void testFooEndpoint() throws Exception {
        // When & Then
        mockMvc.perform(get("/foo")
                .accept(MediaType.APPLICATION_JSON))
                .andExpect(status().isInternalServerError())
                .andExpect(result -> {
                    String response = result.getResponse().getContentAsString();
                    assert response.contains("Server error");
                });
    }
}
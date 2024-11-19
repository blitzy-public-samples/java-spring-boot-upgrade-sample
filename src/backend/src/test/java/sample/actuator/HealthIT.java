package sample.actuator;

// JUnit 5 imports - version 5.9.0
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeAll;

// REST Assured imports - version 5.3.0
import static io.restassured.RestAssured.given;
import io.restassured.RestAssured;

// Hamcrest imports - version 2.2
import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.equalTo;

/**
 * Integration tests for verifying health endpoints and basic functionality 
 * of Spring Boot application in a running container.
 * 
 * Human Tasks:
 * 1. Ensure application is running before executing tests
 * 2. Verify server.port system property is set if not using default 8080
 * 3. Verify server.host system property is set if not using default http://localhost
 */
public class HealthIT {

    /**
     * Static setup method to configure REST Assured test environment
     * Requirement: Health Endpoint Testing - Configure test environment
     */
    @BeforeAll
    public static void setup() {
        // Configure port - use system property or default to 8080
        String port = System.getProperty("server.port");
        if (port == null) {
            RestAssured.port = 8080;
        } else {
            RestAssured.port = Integer.valueOf(port);
        }

        // Configure host - use system property or default to http://localhost
        String baseHost = System.getProperty("server.host");
        if (baseHost == null) {
            baseHost = "http://localhost";
        }
        RestAssured.baseURI = baseHost;
    }

    /**
     * Verifies application is running by checking root endpoint returns 200 OK
     * Requirement: Message Endpoint Testing - Basic application availability check
     */
    @Test
    public void running() {
        given()
            .when()
                .get("/")
            .then()
                .statusCode(200);
    }

    /**
     * Verifies hello message contains expected Spring Boot text
     * Requirement: Message Endpoint Testing - Verify message content
     */
    @Test
    public void message() {
        given()
            .when()
                .get("/")
            .then()
                .body(containsString("Spring boot"));
    }

    /**
     * Verifies hello message exactly matches expected Docker container text
     * Requirement: Message Endpoint Testing - Verify complete message
     */
    @Test
    public void fullMessage() {
        given()
            .when()
                .get("/")
            .then()
                .body("message", equalTo("Spring boot says hello from a Docker container"));
    }

    /**
     * Verifies actuator health endpoint returns UP status
     * Requirement: Health Endpoint Testing - Verify health status
     */
    @Test
    public void health() {
        given()
            .when()
                .get("/actuator/health")
            .then()
                .body("status", equalTo("UP"));
    }
}
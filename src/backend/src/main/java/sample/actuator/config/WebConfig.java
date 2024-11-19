package sample.actuator.config;

// Spring Framework 6.0.0 imports
import org.springframework.context.annotation.Configuration;  
import org.springframework.web.servlet.config.annotation.EnableWebMvc;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import org.springframework.web.servlet.config.annotation.CorsRegistry;

/**
 * Web configuration class for Spring MVC customization with CORS support.
 * 
 * Human Tasks:
 * 1. Verify that the allowed origins pattern /** is appropriate for your production environment
 * 2. Review and adjust the CORS max age setting (3600 seconds) based on your requirements
 * 3. Confirm the list of allowed HTTP methods matches your API requirements
 * 4. Ensure the allowed headers list includes all headers required by your application
 */
@Configuration
@EnableWebMvc
public class WebConfig implements WebMvcConfigurer {

    /**
     * Configures CORS mappings for the application endpoints including actuator endpoints.
     * Implements requirement: "Spring Boot 3 Migration - Configures web components for 
     * Spring Boot 3 compatibility including CORS settings for actuator endpoints"
     *
     * @param registry The CORS registry to configure
     */
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")  // Configure for all endpoints including actuator
            .allowedOriginPatterns("/**")  // Allow all origins - customize for production
            .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")  // Allowed HTTP methods
            .allowedHeaders(  // Allowed headers
                "Authorization",
                "Cache-Control",
                "Content-Type"
            )
            .allowCredentials(true)  // Enable credentials for secure endpoints
            .maxAge(3600);  // Cache CORS preflight requests for 1 hour
    }
}
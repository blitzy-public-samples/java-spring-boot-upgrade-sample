package sample.actuator.config;

// Spring Security 6.0.0
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Bean;

/**
 * Security configuration class that configures Spring Security settings for the application.
 * 
 * Human Tasks:
 * 1. Ensure Spring Security dependencies are included in pom.xml with version 6.0.0 or higher
 * 2. Verify that actuator endpoints are accessible at /actuator/** path
 * 3. Review security settings and adjust based on production requirements
 * 4. Consider implementing proper authentication mechanism instead of basic auth for production
 */
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    /**
     * Configures the security filter chain with appropriate security settings for endpoints.
     * 
     * Requirement Addressed: Spring Boot 3 Migration
     * - Configures security settings compatible with Spring Boot 3
     * - Implements proper authorization rules for web endpoints
     * - Secures actuator endpoints with appropriate access rules
     * 
     * @param http The HttpSecurity instance to configure
     * @return Configured SecurityFilterChain instance
     * @throws Exception if security configuration fails
     */
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            // Disable CSRF for simplicity in sample application
            // In production, consider enabling CSRF protection
            .csrf(csrf -> csrf.disable())
            
            // Configure authorization rules
            .authorizeHttpRequests(authorize -> authorize
                // Allow unrestricted access to root endpoint
                .requestMatchers("/").permitAll()
                // Allow unrestricted access to actuator endpoints
                .requestMatchers("/actuator/**").permitAll()
                // Require authentication for all other requests
                .anyRequest().authenticated()
            )
            
            // Configure HTTP Basic authentication for simplicity
            // In production, consider using form login, OAuth2, or other secure authentication methods
            .httpBasic(basic -> {});

        // Build and return the security filter chain
        return http.build();
    }
}
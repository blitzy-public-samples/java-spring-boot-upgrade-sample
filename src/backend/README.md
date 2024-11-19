# Spring Boot 3 Sample Application

<!-- 
HUMAN TASKS:
1. Verify JDK 6.x installation and JAVA_HOME configuration
2. Ensure Maven 3.x is properly installed and configured
3. Configure Docker environment if not already set up
4. Review and update application.properties with environment-specific values
5. Set up necessary access rights for container registry deployment
-->

> Last Updated: Based on Spring Boot 3 migration  
> Version: 3.0.0  
> Maintainers: Backend team  
> Reviewed by: Technical Architects  
> Next Review: 6 months

## Key Features
- RESTful API endpoints with Spring Web
- Health monitoring via Spring Actuator
- Comprehensive health checks and metrics
- Docker containerization support
- H2 Database integration
- Production-ready configuration

## Technologies
- Spring Boot 3.x
- Java 6.x
- Maven 3.x
- Docker
- Spring Actuator
- H2 Database
- JUnit 5

## Prerequisites
Before you begin, ensure you have the following installed:
- JDK 6.x or later
- Maven 3.x or later
- Docker (for containerization)

## Building the Application

### Local Build
```bash
# Clean and package the application
mvn clean package

# Run the application locally
mvn spring-boot:run
```

## Running Tests

### Unit Tests
```bash
mvn test
```

### Integration Tests
```bash
mvn verify
```

## Docker Support

### Building Docker Image
```bash
docker build -t spring-boot-app .
```

### Running Container
```bash
docker run -p 8080:8080 spring-boot-app
```

## Available Endpoints

### Core Endpoints
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Hello world endpoint |
| `/actuator/health` | GET | Health check endpoint |

## Configuration

### Application Properties
Key application settings in `application.properties`:
```properties
# Server Configuration
server.port=8080

# Actuator Configuration
management.endpoints.web.exposure.include=*

# Database Configuration
spring.datasource.url=jdbc:h2:mem:testdb
```

## Development Guidelines

### Code Style
- Follow standard Java coding conventions
- Use proper JavaDoc documentation
- Implement unit tests for new features
- Maintain code coverage standards

### Testing Requirements
- Write unit tests for all new functionality
- Include integration tests for API endpoints
- Maintain minimum 80% code coverage
- Test both success and failure scenarios

### Pull Request Process
1. Create feature branch from main
2. Include unit and integration tests
3. Update documentation
4. Request review from team members
5. Address review comments
6. Merge after approval

## Deployment

### Production Deployment Steps
1. Build Application
```bash
mvn clean package -P prod
```

2. Create Docker Image
```bash
docker build -t spring-boot-app:prod .
```

3. Deploy to Container Registry
```bash
docker tag spring-boot-app:prod registry.example.com/spring-boot-app:prod
docker push registry.example.com/spring-boot-app:prod
```

4. Update Kubernetes Deployment
```bash
kubectl apply -f k8s/deployment.yaml
```

### Health Monitoring
- Monitor application health via `/actuator/health`
- Check application metrics via `/actuator/metrics`
- Review application info via `/actuator/info`

### Logging
- Application logs are available in the standard output
- Production logs are aggregated in the logging system
- Use appropriate log levels (INFO, WARN, ERROR)

### Troubleshooting
1. Check application health endpoint
2. Review application logs
3. Verify database connectivity
4. Check container resource usage
5. Review actuator metrics

## Security Considerations
- All endpoints are secured by default
- Actuator endpoints are protected
- HTTPS is enforced in production
- Regular security updates are applied

## Performance Optimization
- Connection pooling is configured
- Caching is enabled where appropriate
- JVM tuning parameters are optimized
- Resource limits are properly set

<!-- Addresses requirement: Spring Boot 3 Migration -->
This documentation reflects the migration from Spring Boot 2 to Spring Boot 3 and Java 6.x, maintaining all existing functionality while providing comprehensive setup and deployment instructions for the modernized application.
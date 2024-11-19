# Spring Boot 3 Sample Application

A production-ready Spring Boot 3 application showcasing enterprise features including actuators, REST endpoints, JDBC operations, and Docker support. Built with Spring Boot 3.1.0 and Java 17.

## Prerequisites

- Java 17 or later
- Maven 3.x
- Docker (optional for containerized deployment)
- Spring Boot 3.1.0

## Build Instructions

### Maven Build
```bash
# Clean and package the application
mvn clean package

# Run unit tests
mvn test

# Run integration tests
mvn verify

# Run the application locally
mvn spring-boot:run
```

### Docker Build
```bash
# Build Docker image
docker build -t spring-boot-sample .

# Run Docker container
docker run -p 8080:8080 spring-boot-sample
```

## Configuration

### Application Properties
The application can be configured through `application.properties` or environment variables:

#### Management Endpoints
```properties
management.server.address=127.0.0.1
management.endpoints.web.exposure.include=*
```

#### Server Settings
```properties
server.tomcat.accesslog.enabled=true
server.tomcat.accesslog.pattern=%h %t "%r" %s %b
```

### Environment Variables
Key environment variables that can be customized:
- `JAVA_OPTS`: JVM options
- `SERVER_PORT`: Application port (default: 8080)
- `MANAGEMENT_SERVER_PORT`: Actuator endpoints port (default: 8081)

## Testing

### Unit Tests
```bash
# Run unit tests
mvn test
```
- Uses JUnit Jupiter with spring-boot-starter-test
- H2 in-memory database for data layer testing
- Mockito for mocking dependencies

### Integration Tests
```bash
# Run integration tests
mvn verify
```
- REST Assured 5.3.0 for API testing
- Configurable test properties in application-test.properties
- Separate integration test profile

## Deployment

### Docker Deployment
1. Build the Docker image:
```bash
docker build -t spring-boot-sample .
```

2. Run the container:
```bash
docker run -d \
  -p 8080:8080 \
  -p 8081:8081 \
  --name spring-boot-app \
  spring-boot-sample
```

### Health Monitoring
- Health check endpoint: `/actuator/health`
- Metrics endpoint: `/actuator/metrics`
- Environment information: `/actuator/env`

### Production Considerations
1. Enable HTTPS in production
2. Configure appropriate logging levels
3. Set up monitoring and alerting
4. Configure database connection pooling
5. Enable access logging for audit trails

## Features

- Spring Boot 3.1.0 framework
- Java 17 language features
- RESTful API endpoints
- Spring Boot Actuator for monitoring
- H2 Database support
- Docker containerization
- Maven build system
- Comprehensive test suite
- Production-ready configurations

## Project Structure

```
src/
├── main/
│   ├── java/
│   │   └── sample/
│   │       └── actuator/
│   └── resources/
│       ├── application.properties
│       └── logback.xml
├── test/
│   ├── java/
│   └── resources/
└── pom.xml
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
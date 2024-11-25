# Stage 1: Build the application using Maven
# Maven 3.9.4 with Eclipse Temurin JDK 17 for building the application
FROM maven:3.9.4-eclipse-temurin-17 AS MAVEN_BUILD

# Copy pom.xml first to leverage Docker cache for dependencies
COPY pom.xml /tmp/
WORKDIR /tmp/

# Download dependencies
# This layer will be cached unless pom.xml changes
RUN mvn -B dependency:go-offline

# Copy source code
COPY src /tmp/src/

# Build the application
# Addresses requirement: Java Version Migration - Converting to Spring Boot 3 and Java 17
RUN mvn -B package

# Stage 2: Runtime environment
# Eclipse Temurin JRE 17 for minimal runtime image
FROM eclipse-temurin:21-jre-jammy

# Add metadata labels
LABEL maintainer="Spring Boot Sample Application Team" \
      version="2.0.2" \
      description="Spring Boot 3 Application with Actuator"

# Create application directory
RUN mkdir /app
WORKDIR /app

# Copy the built artifact from builder stage
# Addresses requirement: Application Containerization - Package Spring Boot application
COPY --from=MAVEN_BUILD /tmp/target/*.jar /app/spring-boot-application.jar

# Expose application port
EXPOSE 8080

# Configure JVM runtime parameters
ARG JAVA_OPTS="-Xmx512m -Xms256m"
ENV JAVA_OPTS=$JAVA_OPTS

# Configure server port
ARG SERVER_PORT=8080
ENV SERVER_PORT=$SERVER_PORT

# Set the entry point
# Addresses requirement: Java Version Migration - Configuring Java 17 runtime environment
ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "/app/spring-boot-application.jar"]

# Configure health check using Spring Boot Actuator
# Addresses requirement: Health Monitoring - Implement container health check
HEALTHCHECK --interval=1m --timeout=3s \
    CMD wget -q -T 3 -s http://localhost:8080/actuator/health/ || exit 1
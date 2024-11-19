# Spring Boot Sample Tech Spec

Convert the following Java repository to Spring Boot 3 and Java 6.x. Preserve all the files, retain the existing repository and code structure.

src/main/java/sample/actuator/ExampleHealthIndicator.java

```java

package sample.actuator;

import org.springframework.boot.actuate.health.Health;

import org.springframework.boot.actuate.health.HealthIndicator;

import org.springframework.stereotype.Component;

@Component

public class ExampleHealthIndicator implements HealthIndicator {

@Override

public Health health() {

return Health.up().withDetail("counter", 42).build();

}

}

```

src/main/java/sample/actuator/ExampleInfoContributor.java

```java

package sample.actuator;

import java.util.Collections;

import org.springframework.boot.actuate.info.Info;

import org.springframework.boot.actuate.info.InfoContributor;

import org.springframework.stereotype.Component;

@Component

public class ExampleInfoContributor implements InfoContributor {

@Override

public void contribute(Info.Builder builder) {

builder.withDetail("example", Collections.singletonMap("someKey", "someValue"));

}

}

```

src/main/java/sample/actuator/HelloWorldService.java

```java

package sample.actuator;

import org.springframework.stereotype.Service;

@Service

public class HelloWorldService {

public String getHelloMessage() {

return "Spring boot says hello from a Docker container";

}

}

```

src/main/java/sample/actuator/SampleActuatorApplication.java

```java

package sample.actuator;

import org.springframework.boot.SpringApplication;

import org.springframework.boot.actuate.health.Health;

import org.springframework.boot.actuate.health.HealthIndicator;

import org.springframework.boot.autoconfigure.SpringBootApplication;

import org.springframework.boot.context.properties.EnableConfigurationProperties;

import org.springframework.context.annotation.Bean;

@SpringBootApplication

@EnableConfigurationProperties(ServiceProperties.class)

public class SampleActuatorApplication {

public static void main(String[] args) {

SpringApplication.run(SampleActuatorApplication.class, args);

}

@Bean

public HealthIndicator helloHealthIndicator() {

return new HealthIndicator() {

@Override

public Health health() {

return Health.up().withDetail("hello", "world").build();

}

};

}

}

```

src/main/java/sample/actuator/SampleController.java

```java

package sample.actuator;

import java.util.Collections;

import java.util.Date;

import java.util.LinkedHashMap;

import java.util.Map;

import javax.validation.constraints.NotBlank;

import org.springframework.context.annotation.Description;

import org.springframework.http.MediaType;

import org.springframework.stereotype.Controller;

import org.springframework.validation.annotation.Validated;

import org.springframework.web.bind.annotation.GetMapping;

import org.springframework.web.bind.annotation.PostMapping;

import org.springframework.web.bind.annotation.RequestMapping;

import org.springframework.web.bind.annotation.ResponseBody;

@Controller

@Description("A controller for handling requests for hello messages")

public class SampleController {

private final HelloWorldService helloWorldService;

public SampleController(HelloWorldService helloWorldService) {

this.helloWorldService = helloWorldService;

}

@GetMapping(value = "/", produces = MediaType.APPLICATION_JSON_VALUE)

@ResponseBody

public Map<String, String> hello() {

return Collections.singletonMap("message",

this.helloWorldService.getHelloMessage());

}

@PostMapping(value = "/", produces = MediaType.APPLICATION_JSON_VALUE)

@ResponseBody

public Map<String, Object> olleh(@Validated Message message) {

Map<String, Object> model = new LinkedHashMap<>();

model.put("message", message.getValue());

model.put("title", "Hello Home");

model.put("date", new Date());

return model;

}

@RequestMapping("/foo")

@ResponseBody

public String foo() {

throw new IllegalArgumentException("Server error");

}

protected static class Message {

@NotBlank(message = "Message value cannot be empty")

private String value;

public String getValue() {

return this.value;

}

public void setValue(String value) {

this.value = value;

}

}

}

```

src/main/java/sample/actuator/ServiceProperties.java

```java

package sample.actuator;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "service", ignoreUnknownFields = false)

public class ServiceProperties {

/**

* Name of the service.

*/

private String name = "World";

public String getName() {

return this.name;

}

public void setName(String name) {

this.name = name;

}

}

```

src/test/resources/application-endpoints.properties

```properties

server.error.path: /oops

management.endpoint.health.show-details: always

management.endpoints.web.base-path: /admin

```

src/main/resources/application.properties

```properties

# logging.file=/tmp/logs/app.log

# logging.level.org.springframework.security=DEBUG

management.server.address=127.0.0.1

management.endpoints.web.exposure.include=*

management.endpoint.shutdown.enabled=true

server.tomcat.accesslog.enabled=true

server.tomcat.accesslog.pattern=%h %t "%r" %s %b

#spring.jackson.serialization.INDENT_OUTPUT=true

spring.jmx.enabled=true

spring.jackson.serialization.write_dates_as_timestamps=false

management.httptrace.include=REQUEST_HEADERS,RESPONSE_HEADERS,PRINCIPAL,REMOTE_ADDRESS,SESSION_ID

```

src/main/resources/logback.xml

```xml

<?xml version="1.0" encoding="UTF-8"?>

<configuration>

<include resource="org/springframework/boot/logging/logback/base.xml" />

<root level="INFO">

<appender-ref ref="CONSOLE" />

</root>

</configuration>

```

src/test/java/sample/actuator/ExampleInfoContributorTest.java

```java

package sample.actuator;

import static org.mockito.ArgumentMatchers.any;

import static org.mockito.Mockito.mock;

import static org.mockito.Mockito.verify;

import org.junit.Test;

import org.springframework.boot.actuate.info.Info;

public class ExampleInfoContributorTest {

@Test

public void infoMap() {

Info.Builder builder = mock(Info.Builder.class);

ExampleInfoContributor exampleInfoContributor = new ExampleInfoContributor();

exampleInfoContributor.contribute(builder);

verify(builder).withDetail(any(),any());

}

}

```

src/test/java/sample/actuator/HealthIT.java

```java

package sample.actuator;

import org.junit.Test;

import org.junit.BeforeClass;

import static io.restassured.RestAssured.given;

import io.restassured.RestAssured;

import static org.hamcrest.Matchers.containsString;

import static org.hamcrest.Matchers.equalTo;

public class HealthIT {

@BeforeClass

public static void setup() {

String port = System.getProperty("server.port");

if (port == null) {

RestAssured.port = Integer.valueOf(8080);

}

else{

RestAssured.port = Integer.valueOf(port);

}

String baseHost = System.getProperty("server.host");

if(baseHost==null){

baseHost = "http://localhost";

}

RestAssured.baseURI = baseHost;

}

@Test

public void running() {

given().when().get("/")

.then().statusCode(200);

}

@Test

public void message() {

given().when().get("/")

.then().body(containsString("Spring boot"));

}

@Test

public void fullMessage() {

given().when().get("/")

.then().body("message",equalTo("Spring boot says hello from a Docker container"));

}

@Test

public void health() {

given().when().get("/actuator/health")

.then().body("status",equalTo("UP"));

}

}

```

src/test/java/sample/actuator/HelloWorldServiceTest.java

```java

package sample.actuator;

import static org.junit.Assert.assertEquals;

import org.junit.Test;

public class HelloWorldServiceTest {

@Test

public void expectedMessage() {

HelloWorldService helloWorldService = new HelloWorldService();

assertEquals("Expected correct message","Spring boot says hello from a Docker container",helloWorldService.getHelloMessage());

}

}

```

src/test/resources/application-endpoints.properties

```properties

server.error.path: /oops

management.endpoint.health.show-details: always

management.endpoints.web.base-path: /admin

```

.gitignore

```gitignore

- #
- .iml
- .ipr
- .iws
- .jar
- .sw?
- ~

.#*

.*.md.html

.DS_Store

.classpath

.factorypath

.gradle

.idea

.metadata

.project

.recommenders

.settings

.springBeans

/build

/code

MANIFEST.MF

_site/

activemq-data

bin

build

build.log

dependency-reduced-pom.xml

dump.rdb

interpolated*.xml

lib/

manifest.yml

overridedb.*

settings.xml

target

transaction-logs

.flattened-pom.xml

secrets.yml

.gradletasknamecache

.sts4-cache

```

Dockerfile

```Dockerfile

FROM maven:3.5.2-jdk-8-alpine AS MAVEN_TOOL_CHAIN

COPY pom.xml /tmp/

RUN mvn -B dependency:go-offline -f /tmp/pom.xml -s /usr/share/maven/ref/settings-docker.xml

COPY src /tmp/src/

WORKDIR /tmp/

RUN mvn -B -s /usr/share/maven/ref/settings-docker.xml package

FROM java:8-jre-alpine

EXPOSE 8080

RUN mkdir /app

COPY --from=MAVEN_TOOL_CHAIN /tmp/target/*.jar /app/spring-boot-application.jar

ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app/spring-boot-application.jar"]

HEALTHCHECK --interval=1m --timeout=3s CMD wget -q -T 3 -s http://localhost:8080/actuator/health/ || exit 1

```

Dockerfile.only-package

```only-package

FROM java:8-jre-alpine

EXPOSE 8080

RUN mkdir /app

COPY target/*.jar /app/spring-boot-application.jar

ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app/spring-boot-application.jar"]

HEALTHCHECK --interval=1m --timeout=3s CMD wget -q -T 3 -s http://localhost:8080/actuator/health/ || exit 1

```

README.md

```md

**# Dockerized Spring boot 2 application**

![Docker plus Spring Boot plus Codefresh](docker-spring-boot-codefresh.jpg)

This is an example Java application that uses Spring Boot 2, Maven and Docker.

It is compiled using Codefresh.

If you are looking for Gradle, then see this [example](https://github.com/codefresh-contrib/gradle-sample-app)

**## Instructions**

To compile (also runs unit tests)

```

mvn package

```

## To run the webapp manually

```

mvn spring-boot:run

```

....and navigate your browser to  http://localhost:8080/

## To run integration tests

```

mvn spring-boot:run

mvn verify

```

## To create a docker image packaging an existing jar

```

mvn package

docker build -t my-spring-boot-sample . -f Dockerfile.only-package

```

## Create a multi-stage docker image

To compile and package using Docker multi-stage builds

```bash

docker build . -t my-spring-boot-sample

```

**## To run the docker image**

```

docker run -p 8080:8080 my-spring-boot-sample

```

The Dockerfile also has a healthcheck

**## To use this project in Codefresh**

There is also a [codefresh.yml](codefresh.yml) for easy usage with the [Codefresh](codefresh.io) CI/CD platform.

For the simple packaging pipeline see [codefresh-package-only.yml](codefresh-package-only.yml)

More details can be found in [Codefresh documentation](https://codefresh.io/docs/docs/learn-by-example/java/spring-boot-2/)

Enjoy!

```

codefresh-package-only.yml

```yml

version: '1.0'

stages:

- prepare

- test

- build

- 'integration test'

steps:

main_clone:

title: Cloning main repository...

stage: prepare

type: git-clone

repo: 'codefresh-contrib/spring-boot-2-sample-app'

revision: master

git: github

run_unit_tests:

title: Compile/Unit test

stage: test

image: 'maven:3.5.2-jdk-8-alpine'

commands:

- mvn -Dmaven.repo.local=/codefresh/volume/m2_repository package

build_app_image:

title: Building Docker Image

type: build

stage: build

image_name: spring-boot-2-sample-app

working_directory: ./

tag: 'non-multi-stage'

dockerfile: Dockerfile.only-package

run_integration_tests:

title: Integration test

stage: 'integration test'

image: maven:3.5.2-jdk-8-alpine

commands:

- mvn -Dmaven.repo.local=/codefresh/volume/m2_repository verify -Dserver.host=http://my-spring-app

services:

composition:

my-spring-app:

image: '${{build_app_image}}'

ports:

- 8080

readiness:

timeoutSeconds: 30

periodSeconds: 15

image: byrnedo/alpine-curl

commands:

- "curl http://my-spring-app:8080/"

```

codefresh.yml

```yml

version: '1.0'

stages:

- prepare

- test

- build

- 'integration test'

steps:

main_clone:

title: Cloning main repository...

stage: prepare

type: git-clone

repo: 'codefresh-contrib/spring-boot-2-sample-app'

revision: master

git: github

run_unit_tests:

title: Compile/Unit test

stage: test

image: 'maven:3.5.2-jdk-8-alpine'

commands:

- mvn -Dmaven.repo.local=/codefresh/volume/m2_repository test

build_app_image:

title: Building Docker Image

type: build

stage: build

image_name: spring-boot-2-sample-app

working_directory: ./

tag: 'multi-stage'

dockerfile: Dockerfile

run_integration_tests:

title: Integration test

stage: 'integration test'

image: maven:3.5.2-jdk-8-alpine

commands:

- mvn -Dmaven.repo.local=/codefresh/volume/m2_repository verify -Dserver.host=http://my-spring-app

services:

composition:

my-spring-app:

image: '${{build_app_image}}'

ports:

- 8080

readiness:

timeoutSeconds: 30

periodSeconds: 15

image: byrnedo/alpine-curl

commands:

- "curl http://my-spring-app:8080/"

```

pom.xml

```xml

<?xml version="1.0" encoding="UTF-8"?>

<project xmlns="http://maven.apache.org/POM/4.0.0"

xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"

xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">

<modelVersion>4.0.0</modelVersion>

<artifactId>spring-boot-sample-actuator</artifactId>

<name>Spring Boot Actuator Sample</name>

<version>2.0.2</version>

<description>Spring Boot Actuator Sample</description>

<packaging>jar</packaging>

<parent>

<groupId>org.springframework.boot</groupId>

<artifactId>spring-boot-starter-parent</artifactId>

<version>2.0.2.RELEASE</version>

<relativePath /> <!-- lookup parent from repository -->

</parent>

<properties>

<java.version>1.8</java.version>

</properties>

<dependencies>

<!-- Compile -->

<dependency>

<groupId>org.springframework.boot</groupId>

<artifactId>spring-boot-starter-actuator</artifactId>

</dependency>

<dependency>

<groupId>org.springframework.boot</groupId>

<artifactId>spring-boot-starter-web</artifactId>

</dependency>

<dependency>

<groupId>org.springframework.boot</groupId>

<artifactId>spring-boot-starter-jdbc</artifactId>

</dependency>

<!-- Runtime -->

<dependency>

<groupId>org.apache.httpcomponents</groupId>

<artifactId>httpclient</artifactId>

<scope>runtime</scope>

</dependency>

<dependency>

<groupId>com.h2database</groupId>

<artifactId>h2</artifactId>

<scope>runtime</scope>

</dependency>

<!-- Optional -->

<dependency>

<groupId>org.springframework.boot</groupId>

<artifactId>spring-boot-configuration-processor</artifactId>

<optional>true</optional>

</dependency>

<!-- Test -->

<dependency>

<groupId>org.springframework.boot</groupId>

<artifactId>spring-boot-starter-test</artifactId>

<scope>test</scope>

</dependency>

<dependency>

<groupId>io.rest-assured</groupId>

<artifactId>rest-assured</artifactId>

<scope>test</scope>

</dependency>

<dependency>

<groupId>org.codehaus.groovy</groupId>

<artifactId>groovy-all</artifactId>

<scope>test</scope>

</dependency>

</dependencies>

<build>

<plugins>

<plugin>

<groupId>org.springframework.boot</groupId>

<artifactId>spring-boot-maven-plugin</artifactId>

</plugin>

<plugin>

<groupId>org.apache.maven.plugins</groupId>

<artifactId>maven-surefire-plugin</artifactId>

<version>2.9</version>

<configuration>

<useFile>false</useFile>

<includes>

<include>**/*Test.java</include>

</includes>

</configuration>

</plugin>

<plugin>

<groupId>org.apache.maven.plugins</groupId>

<artifactId>maven-failsafe-plugin</artifactId>

<version>2.18</version>

<executions>

<execution>

<goals>

<goal>integration-test</goal>

<goal>verify</goal>

</goals>

</execution>

</executions>

<configuration>

<useFile>false</useFile>

<includes>

<include>**/*IT.java</include>

</includes>

</configuration>

</plugin>

</plugins>

</build>

</project>

```

docker-spring-boot-codefresh.jpg

```

Binary image file with Docker, Springboot and codefresh logos

```
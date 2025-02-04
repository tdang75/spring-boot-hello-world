# Stage 1: Build the Spring Boot JAR
FROM maven:3.8.3-openjdk-17 AS builder

WORKDIR /app

# Copy pom.xml and download dependencies (to leverage Docker caching)
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy the actual project files and build the application
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Create a minimal runtime image
FROM amazoncorretto:17-alpine

WORKDIR /app

# Copy the built JAR from the previous stage
COPY --from=builder /app/target/*.jar app.jar

# Expose the application's port
EXPOSE 8080

# Run the Spring Boot application
ENTRYPOINT ["java", "-jar", "app.jar"]

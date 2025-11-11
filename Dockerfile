# ============================
# 🔹 1. Build Stage
# ============================
FROM eclipse-temurin:21-jdk-jammy AS build
WORKDIR /app

# Add Maven wrapper and config with correct permissions
COPY mvnw ./
COPY .mvn .mvn/
RUN chmod +x mvnw

# Cache Maven dependencies
COPY pom.xml .
RUN ./mvnw dependency:go-offline -B

# Copy source code and build
COPY src ./src
RUN ./mvnw clean package -DskipTests

# ============================
# 🔹 2. Runtime Stage
# ============================
FROM eclipse-temurin:21-jre-jammy AS runtime
LABEL maintainer="email2ashusharma@gmail.com"
LABEL version="1.0.0"
WORKDIR /app

# Create non-root user to run the app securely
RUN useradd -r -u 1000 -s /usr/sbin/nologin springuser

# Copy jar from build stage using fixed name assuming target artifact name is app.jar
COPY --from=build /app/target/app.jar ./app.jar

# Change ownership to springuser
RUN chown springuser:springuser ./app.jar

USER springuser

EXPOSE 8080

ENTRYPOINT ["java", \
            "-XX:+UseContainerSupport", \
            "-XX:MaxRAMPercentage=75.0", \
            "-XX:+ExitOnOutOfMemoryError", \
            "-jar", "app.jar"]

# ============================
# 🔹 1. Build Stage
# ============================
FROM eclipse-temurin:21-jdk-jammy AS build
WORKDIR /app

COPY pom.xml .
COPY mvnw ./
COPY .mvn ./.mvn
RUN chmod +x mvnw
RUN ./mvnw dependency:go-offline -B

COPY src ./src
RUN ./mvnw clean package -DskipTests

# ============================
# 🔹 2. Runtime Stage
# ============================
FROM eclipse-temurin:21-jre-jammy AS runtime
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar

RUN useradd -r -s /bin/false springuser
USER springuser

EXPOSE 8080

ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=75.0", "-XX:+ExitOnOutOfMemoryError", "-jar", "app.jar"]

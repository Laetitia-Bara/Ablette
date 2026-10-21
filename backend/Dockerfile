# syntax=docker/dockerfile:1
FROM eclipse-temurin:21-jdk-alpine AS build
WORKDIR /workspace
COPY .mvn .mvn
COPY mvnw pom.xml ./
RUN --mount=type=cache,target=/root/.m2 \
    sed -i 's/\r$//' mvnw && chmod +x mvnw && ./mvnw -B -ntp dependency:go-offline
COPY src src
RUN --mount=type=cache,target=/root/.m2 ./mvnw -B -ntp -DskipTests package

FROM eclipse-temurin:21-jre-alpine
RUN addgroup -S ablette && adduser -S -G ablette ablette
WORKDIR /app
COPY --from=build /workspace/target/ablette-api-0.1.0-SNAPSHOT.jar app.jar
USER ablette
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/app.jar"]

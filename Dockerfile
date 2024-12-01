# Крок 1: Будуємо JAR-файл за допомогою Maven
FROM maven:3.8.5-openjdk-17 AS builder
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn clean package -DskipTests

# Крок 2: Створюємо кінцевий образ
FROM openjdk:17-jdk-slim
WORKDIR /app
COPY --from=builder /app/target/CleaningWebService-0.0.1-SNAPSHOT.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
EXPOSE 8080

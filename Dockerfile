# Використовуємо офіційний образ Java
FROM openjdk:17-jdk-slim

# Встановлюємо робочу директорію
WORKDIR /app

# Копіюємо зібраний JAR-файл до контейнера
COPY target/CleaningWebService-0.0.1-SNAPSHOT.jar app.jar


# Вказуємо команду запуску Spring Boot
ENTRYPOINT ["java", "-jar", "app.jar"]

# Відкриваємо порт для сервера
EXPOSE 8080

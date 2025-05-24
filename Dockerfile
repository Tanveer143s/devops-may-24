# --- Stage 1: Build frontend ---
FROM node:18-alpine AS frontend-build
WORKDIR /app
COPY frontend/package*.json ./
RUN npm install
COPY frontend/ .
RUN npm run build

# --- Stage 2: Build backend (Java 17 with Maven) ---
FROM maven:3.8.6-openjdk-17 AS backend-build
WORKDIR /app
COPY backend/pom.xml .
COPY backend/src ./src
RUN mvn clean package -DskipTests

# --- Final Stage: Combine ---
FROM openjdk:17-jdk-slim
WORKDIR /app
COPY --from=backend-build /app/target/*.jar app.jar
COPY --from=frontend-build /app/build /app/static
# Expose application on this port
EXPOSE 8080
# Run the app using following default command  argument
CMD ["java", "-jar", "app.jar"]

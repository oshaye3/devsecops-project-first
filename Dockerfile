# Use an OpenJDK 21 base image
FROM openjdk:21-jdk as build
WORKDIR /app

COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
COPY src src

# Ensure Maven Wrapper has execute permissions
RUN chmod +x ./mvnw && \
    ./mvnw package

# Copy the built jar file to the app directory
COPY target/*.jar app.jar

# For the final image, you can continue to use the same JDK 21 base image
FROM openjdk:21-jdk
VOLUME /tmp

# Create a non-root user and group 'javauser' to run the application
RUN groupadd --system javauser && \
    useradd -s /bin/false -g javauser -G javauser javauser

WORKDIR /app
# Copy the jar file from the build stage to the /app directory
COPY --from=build /app/app.jar .

# Change ownership of the /app directory to the 'javauser'
RUN chown -R javauser:javauser /app

# Use the non-root user to run the application
USER javauser

# Run the application
ENTRYPOINT ["java","-jar","app.jar"]

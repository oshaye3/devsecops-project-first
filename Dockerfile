FROM alpine:3.15 as build
WORKDIR /app

COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
COPY src src

RUN ./mvnw package
COPY target/*.jar app.jar

FROM alpine:3.15
VOLUME /tmp
RUN addgroup --system javauser && adduser -S -s /bin/false -G javauser javauser
WORKDIR /app
COPY --from=build /app/app.jar .
RUN chown -R javauser:javauser /app
USER javauser
ENTRYPOINT ["java","-jar","app.jar"]

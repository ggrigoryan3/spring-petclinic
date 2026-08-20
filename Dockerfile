FROM maven:3.9.9-eclipse-temurin-17 AS builder

WORKDIR /build

COPY pom.xml .

COPY src ./src

RUN mvn clean package -DskipTests

FROM eclipse-temurin:17-jre-jammy

WORKDIR /app

ADD https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.20.0/jmx_prometheus_javaagent-0.20.0.jar /app/jmx_prometheus_javaagent.jar

COPY config.yml /app/config.yml

COPY --from=builder /build/target/spring-petclinic-*.jar app.jar

EXPOSE 8080 9404

ENTRYPOINT ["java", "-javaagent:/app/jmx_prometheus_javaagent.jar=9404:/app/config.yml", "-Dspring.profiles.active=postgres", "-jar", "app.jar"]
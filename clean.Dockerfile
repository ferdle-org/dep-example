ARG CODEARTIFACT_AUTH_TOKEN

FROM openjdk:18 as app-build

WORKDIR /workspace/app

ARG CODEARTIFACT_AUTH_TOKEN

RUN adduser --system --home /var/cache/bootapp --shell /sbin/nologin bootapp;
RUN microdnf install findutils

COPY gradle gradle
COPY gradlew gradlew
COPY settings.gradle.kts settings.gradle.kts
COPY build.gradle.kts build.gradle.kts

RUN rm -rf mogo-plus-api/src mogo-plus-service/src mogo-plus-tpi-api/src
RUN rm -rf mogo-plus-api/build mogo-plus-service/build mogo-plus-tpi-api/build

COPY mogo-plus-api/build.gradle.kts mogo-plus-api/build.gradle.kts
COPY mogo-plus-api/src mogo-plus-api/src
COPY mogo-plus-tpi-api/build.gradle.kts mogo-plus-tpi-api/build.gradle.kts
COPY mogo-plus-tpi-api/src mogo-plus-tpi-api/src
COPY mogo-plus-service/build.gradle.kts mogo-plus-service/build.gradle.kts
COPY mogo-plus-service/src mogo-plus-service/src

ENV GRADLE_USER_HOME=./.gradle
ENV GRADLE_OPTS="-Djava.io.tmpdir=./.gradle"

RUN ./gradlew clean mogo-plus-service:compileTestJava mogo-plus-service:compileTestKotlin :mogo-plus-service:build --build-cache --no-daemon --info --exclude-task check
RUN mkdir -p mogo-plus-service/build/dependency && (cd mogo-plus-service/build/dependency; jar -xf ../libs/*.jar)

ADD https://github.com/aws-observability/aws-otel-java-instrumentation/releases/latest/download/aws-opentelemetry-agent.jar aws-opentelemetry-agent.jar

RUN chmod 755 aws-opentelemetry-agent.jar
FROM 704209381676.dkr.ecr.ap-southeast-2.amazonaws.com/mogo-plus-tpi:app-build as app-build

FROM gcr.io/distroless/java17-debian11 as app-package

COPY --from=app-build /etc/passwd /etc/shadow /etc/

USER bootapp

VOLUME /tmp

ARG DEPENDENCY=/workspace/app/mogo-plus-service/build/dependency

COPY --from=app-build ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY --from=app-build ${DEPENDENCY}/META-INF /app/META-INF
COPY --from=app-build ${DEPENDENCY}/BOOT-INF/classes /app
COPY --from=app-build /workspace/app/aws-opentelemetry-agent.jar /opt/aws-opentelemetry-agent.jar

ENTRYPOINT ["java","-javaagent:/opt/aws-opentelemetry-agent.jar","-cp","app:app/lib/*","au.com.adatree.tpi.mogoplus.ApplicationKt"]

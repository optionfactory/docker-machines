#!/bin/bash -e
exec gosu sonarqube:docker-machines  java \
    -Xms8m \
    -Xmx32m \
    --add-exports=java.base/jdk.internal.ref=ALL-UNNAMED \
    --add-opens=java.base/java.lang=ALL-UNNAMED \
    --add-opens=java.base/java.nio=ALL-UNNAMED \
    --add-opens=java.base/sun.nio.ch=ALL-UNNAMED \
    --add-opens=java.management/sun.management=ALL-UNNAMED \
    --add-opens=jdk.management/com.sun.management.internal=ALL-UNNAMED \
    -jar /opt/sonarqube/lib/sonar-application-*.jar

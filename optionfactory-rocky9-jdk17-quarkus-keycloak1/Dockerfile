FROM optionfactory/rocky9-jdk17:latest
LABEL maintainer="Roberto Ferranti <roberto@optionfactory.net>"

COPY deps /tmp/

RUN DISTRIB_LABEL=rocky9 DISTRIB_ID=rocky DISTRIB_RELEASE=9 DISTRIB_CODENAME=9 /tmp/install-quarkus-keycloak1.sh
RUN cp /tmp/init-quarkus-keycloak1.sh /keycloak
RUN rm -rf /tmp/*

EXPOSE 8080

ENTRYPOINT ["/keycloak"]

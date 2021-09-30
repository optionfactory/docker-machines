FROM optionfactory/debian11-jdk11:latest
MAINTAINER Roberto Ferranti <roberto@optionfactory.net>

COPY deps /tmp/

RUN DISTRIB_LABEL=debian11 DISTRIB_ID=debian DISTRIB_RELEASE=11 DISTRIB_CODENAME=bullseye /tmp/install-keycloak12.sh
RUN cp /tmp/init-keycloak12.sh /keycloak
RUN rm -rf /tmp/*

EXPOSE 8080

ENTRYPOINT ["/keycloak"]

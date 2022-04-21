FROM optionfactory/ubuntu22-jdk17:latest
MAINTAINER Roberto Ferranti <roberto@optionfactory.net>

COPY deps /tmp/

RUN DISTRIB_LABEL=ubuntu22 DISTRIB_ID=ubuntu DISTRIB_RELEASE=22.04 DISTRIB_CODENAME=jammy /tmp/install-keycloak16.sh
RUN cp /tmp/init-keycloak16.sh /keycloak
RUN rm -rf /tmp/*

EXPOSE 8080

ENTRYPOINT ["/keycloak"]

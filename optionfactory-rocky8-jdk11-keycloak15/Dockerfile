FROM optionfactory/rocky8-jdk11:latest
MAINTAINER Roberto Ferranti <roberto@optionfactory.net>

COPY deps /tmp/

RUN DISTRIB_LABEL=rocky8 DISTRIB_ID=rocky DISTRIB_RELEASE=8 DISTRIB_CODENAME=8 /tmp/install-keycloak15.sh
RUN cp /tmp/init-keycloak15.sh /keycloak
RUN rm -rf /tmp/*

EXPOSE 8080

ENTRYPOINT ["/keycloak"]

FROM optionfactory/debian10-jdk17:latest
MAINTAINER Roberto Ferranti <roberto@optionfactory.net>

COPY deps /tmp/

RUN DISTRIB_LABEL=debian10 DISTRIB_ID=debian DISTRIB_RELEASE=10 DISTRIB_CODENAME=buster /tmp/install-keycloak15.sh
RUN cp /tmp/init-keycloak15.sh /keycloak
RUN rm -rf /tmp/*

EXPOSE 8080

ENTRYPOINT ["/keycloak"]

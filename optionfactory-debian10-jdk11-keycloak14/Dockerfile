FROM optionfactory/debian10-jdk11:latest
MAINTAINER Roberto Ferranti <roberto@optionfactory.net>

COPY deps /tmp/

RUN DISTRIB_LABEL=debian10 DISTRIB_ID=debian DISTRIB_RELEASE=10 DISTRIB_CODENAME=buster /tmp/install-keycloak14.sh
RUN cp /tmp/init-keycloak14.sh /keycloak
RUN rm -rf /tmp/*

EXPOSE 8080

ENTRYPOINT ["/keycloak"]

FROM optionfactory/centos8-jdk11:latest
MAINTAINER Roberto Ferranti <roberto@optionfactory.net>

COPY deps /tmp/

RUN /tmp/install-keycloak9.sh
RUN cp /tmp/init-keycloak9.sh /keycloak
RUN rm -rf /tmp/*

EXPOSE 8080

ENTRYPOINT ["/keycloak"]

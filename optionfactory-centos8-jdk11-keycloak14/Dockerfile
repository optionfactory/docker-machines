FROM optionfactory/centos8-jdk11:latest
MAINTAINER Roberto Ferranti <roberto@optionfactory.net>

COPY deps /tmp/

RUN DISTRIB_LABEL=centos8 DISTRIB_ID=centos DISTRIB_RELEASE=8 DISTRIB_CODENAME=8 /tmp/install-keycloak14.sh
RUN cp /tmp/init-keycloak14.sh /keycloak
RUN rm -rf /tmp/*

EXPOSE 8080

ENTRYPOINT ["/keycloak"]

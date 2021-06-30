FROM optionfactory/ubuntu20-jdk11:latest
MAINTAINER Roberto Ferranti <roberto@optionfactory.net>

COPY deps /tmp/

RUN DISTRIB_LABEL=ubuntu20 DISTRIB_ID=ubuntu DISTRIB_RELEASE=20.04 DISTRIB_CODENAME=focal /tmp/install-keycloak14.sh
RUN cp /tmp/init-keycloak14.sh /keycloak
RUN rm -rf /tmp/*

EXPOSE 8080

ENTRYPOINT ["/keycloak"]

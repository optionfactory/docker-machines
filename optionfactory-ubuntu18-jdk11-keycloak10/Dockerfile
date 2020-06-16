FROM optionfactory/ubuntu18-jdk11:latest
MAINTAINER Roberto Ferranti <roberto@optionfactory.net>

COPY deps /tmp/

RUN DISTRIB_LABEL=ubuntu18 DISTRIB_ID=ubuntu DISTRIB_RELEASE=18.04 DISTRIB_CODENAME=bionic /tmp/install-keycloak10.sh
RUN cp /tmp/init-keycloak10.sh /keycloak
RUN rm -rf /tmp/*

EXPOSE 8080

ENTRYPOINT ["/keycloak"]

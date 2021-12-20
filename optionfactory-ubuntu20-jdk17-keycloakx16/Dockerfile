FROM optionfactory/ubuntu20-jdk17:latest
MAINTAINER Roberto Ferranti <roberto@optionfactory.net>

COPY deps /tmp/

RUN DISTRIB_LABEL=ubuntu20 DISTRIB_ID=ubuntu DISTRIB_RELEASE=20.04 DISTRIB_CODENAME=focal /tmp/install-keycloakx16.sh
RUN cp /tmp/init-keycloakx16.sh /keycloakx
RUN rm -rf /tmp/*

EXPOSE 8080

ENTRYPOINT ["/keycloakx"]

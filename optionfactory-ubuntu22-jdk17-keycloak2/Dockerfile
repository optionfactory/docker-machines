FROM optionfactory/ubuntu22-jdk17:latest
LABEL maintainer="Roberto Ferranti <roberto@optionfactory.net>"
LABEL org.opencontainers.image.source https://github.com/optionfactory/docker-machines

COPY deps /tmp/

RUN DISTRIB_LABEL=ubuntu22 DISTRIB_ID=ubuntu DISTRIB_RELEASE=22.04 DISTRIB_CODENAME=jammy /tmp/install-keycloak2.sh
RUN cp /tmp/init-keycloak2.sh /keycloak
RUN rm -rf /tmp/*

EXPOSE 8080

ENTRYPOINT ["/keycloak"]

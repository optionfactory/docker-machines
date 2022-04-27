FROM optionfactory/rocky8-jdk11:latest
LABEL maintainer="Roberto Ferranti <roberto@optionfactory.net>"

COPY deps /tmp/

RUN DISTRIB_LABEL=rocky8 DISTRIB_ID=rocky DISTRIB_RELEASE=8 DISTRIB_CODENAME=8 /tmp/install-wildfly-keycloak1.sh
RUN cp /tmp/init-wildfly-keycloak1.sh /keycloak
RUN rm -rf /tmp/*

EXPOSE 8080

ENTRYPOINT ["/keycloak"]

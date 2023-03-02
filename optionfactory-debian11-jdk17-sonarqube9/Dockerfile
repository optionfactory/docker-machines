FROM optionfactory/debian11-jdk17:latest
LABEL maintainer="Roberto Ferranti <roberto@optionfactory.net>"

COPY deps /tmp/

RUN DISTRIB_LABEL=debian11 DISTRIB_ID=debian DISTRIB_RELEASE=11 DISTRIB_CODENAME=bullseye TOMCAT_MAJOR_VERSION=9 /tmp/install-sonarqube9.sh
RUN cp /tmp/init-sonarqube9.sh /sonarqube
RUN rm -rf /tmp/*

EXPOSE 9000

ENTRYPOINT ["/sonarqube"]

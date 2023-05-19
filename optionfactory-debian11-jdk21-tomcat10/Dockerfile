FROM optionfactory/debian11-jdk21:latest
LABEL maintainer="Roberto Ferranti <roberto@optionfactory.net>"
LABEL org.opencontainers.image.source https://github.com/optionfactory/docker-machines

COPY deps /tmp/

RUN DISTRIB_LABEL=debian11 DISTRIB_ID=debian DISTRIB_RELEASE=11 DISTRIB_CODENAME=bullseye TOMCAT_MAJOR_VERSION=10 /tmp/install-tomcat.sh
RUN cp /tmp/init-tomcat.sh /tomcat
RUN rm -rf /tmp/*

EXPOSE 8084

ENTRYPOINT ["/tomcat"]

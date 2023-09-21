FROM optionfactory/debian12-jdk21:latest
LABEL maintainer="Roberto Ferranti <roberto@optionfactory.net>"
LABEL org.opencontainers.image.source https://github.com/optionfactory/docker-machines

COPY deps /tmp/

RUN DISTRIB_LABEL=debian12 DISTRIB_ID=debian DISTRIB_RELEASE=12 DISTRIB_CODENAME=bookworm TOMCAT_MAJOR_VERSION=9 /tmp/install-tomcat.sh
RUN cp /tmp/init-tomcat.sh /tomcat
RUN rm -rf /tmp/*

EXPOSE 8084

ENTRYPOINT ["/tomcat"]

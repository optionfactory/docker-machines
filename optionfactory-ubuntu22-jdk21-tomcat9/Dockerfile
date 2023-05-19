FROM optionfactory/ubuntu22-jdk21:latest
LABEL maintainer="Roberto Ferranti <roberto@optionfactory.net>"
LABEL org.opencontainers.image.source https://github.com/optionfactory/docker-machines

COPY deps /tmp/

RUN DISTRIB_LABEL=ubuntu22 DISTRIB_ID=ubuntu DISTRIB_RELEASE=22.04 DISTRIB_CODENAME=jammy TOMCAT_MAJOR_VERSION=9 /tmp/install-tomcat.sh
RUN cp /tmp/init-tomcat.sh /tomcat
RUN rm -rf /tmp/*

EXPOSE 8084

ENTRYPOINT ["/tomcat"]

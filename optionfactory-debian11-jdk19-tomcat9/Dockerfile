FROM optionfactory/debian11-jdk19:latest
LABEL maintainer="Roberto Ferranti <roberto@optionfactory.net>"

COPY deps /tmp/

RUN DISTRIB_LABEL=debian11 DISTRIB_ID=debian DISTRIB_RELEASE=11 DISTRIB_CODENAME=bullseye /tmp/install-tomcat9.sh
RUN cp /tmp/init-tomcat9.sh /tomcat
RUN rm -rf /tmp/*

EXPOSE 8084

ENTRYPOINT ["/tomcat"]

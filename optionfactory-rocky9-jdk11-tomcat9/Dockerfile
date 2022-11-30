FROM optionfactory/rocky9-jdk11:latest
LABEL maintainer="Roberto Ferranti <roberto@optionfactory.net>"

COPY deps /tmp/

RUN DISTRIB_LABEL=rocky9 DISTRIB_ID=rocky DISTRIB_RELEASE=9 DISTRIB_CODENAME=9 /tmp/install-tomcat9.sh
RUN cp /tmp/init-tomcat9.sh /tomcat
RUN rm -rf /tmp/*

EXPOSE 8084

ENTRYPOINT ["/tomcat"]

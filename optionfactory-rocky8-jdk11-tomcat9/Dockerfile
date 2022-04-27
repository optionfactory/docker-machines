FROM optionfactory/rocky8-jdk11:latest
LABEL maintainer="Roberto Ferranti <roberto@optionfactory.net>"

COPY deps /tmp/

RUN DISTRIB_LABEL=rocky8 DISTRIB_ID=rocky DISTRIB_RELEASE=8 DISTRIB_CODENAME=8 /tmp/install-tomcat9.sh
RUN cp /tmp/init-tomcat9.sh /tomcat
RUN rm -rf /tmp/*

EXPOSE 8084

ENTRYPOINT ["/tomcat"]

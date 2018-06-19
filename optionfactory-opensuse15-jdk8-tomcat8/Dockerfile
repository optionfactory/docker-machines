FROM optionfactory/opensuse15-jdk8:latest
MAINTAINER Roberto Ferranti <roberto@optionfactory.net>

COPY deps /tmp/

RUN /tmp/install-tomcat8.sh
RUN cp /tmp/init-tomcat8.sh /tomcat
RUN rm -rf /tmp/*

EXPOSE 8080 8443

ENTRYPOINT ["/tomcat"]

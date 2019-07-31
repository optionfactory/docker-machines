FROM optionfactory/debian10-jdk11:latest
MAINTAINER Roberto Ferranti <roberto@optionfactory.net>


COPY deps /tmp/

RUN /tmp/install-tomcat9.sh
RUN cp /tmp/init-tomcat9.sh /tomcat
RUN rm -rf /tmp/*

EXPOSE 8080 8084

ENTRYPOINT ["/tomcat"]

FROM optionfactory/debian8-jdk8:latest
MAINTAINER Roberto Ferranti


COPY deps /tmp/

RUN cp /tmp/gosu-* /usr/local/bin/gosu
RUN /tmp/install-tomcat.sh
RUN cp /tmp/init-tomcat.sh /tomcat
RUN rm -rf /tmp/*

EXPOSE 8080 8084

ENTRYPOINT ["/tomcat"]

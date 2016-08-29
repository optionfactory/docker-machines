FROM optionfactory/opensuse13-jdk8:latest
MAINTAINER Roberto Ferranti

COPY deps /tmp/
RUN /tmp/install-tomcat.sh
RUN cp /tmp/init-tomcat.sh /tomcat
RUN rm -rf /tmp/*

USER tomcat

EXPOSE 8080 8443

ENTRYPOINT ["/tomcat"]
FROM optionfactory/debian-jdk:latest
MAINTAINER Roberto Ferranti


COPY install-tomcat.sh /tmp/install-tomcat.sh
RUN /tmp/install-tomcat.sh && rm /tmp/install-tomcat.sh
COPY logging.properties /opt/apache-tomcat/conf/logging.properties
COPY server.xml /opt/apache-tomcat/conf/server.xml
COPY tomcat /tomcat
RUN groupadd -r tomcat && useradd -r -g tomcat tomcat
RUN chown -R tomcat:tomcat /opt/apache-tomcat

USER tomcat
EXPOSE 8084

ENTRYPOINT ["/tomcat"]

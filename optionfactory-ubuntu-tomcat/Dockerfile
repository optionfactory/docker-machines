FROM optionfactory/ubuntu-jdk:latest
MAINTAINER Roberto Ferranti


COPY Docker-bootstrap.sh /tmp/Docker-bootstrap.sh
RUN /tmp/Docker-bootstrap.sh && rm /tmp/Docker-bootstrap.sh
COPY logging.properties /opt/apache-tomcat/conf/logging.properties
COPY server.xml /opt/apache-tomcat/conf/server.xml
COPY Docker-entrypoint.sh /entrypoint.sh
RUN groupadd -r tomcat && useradd -r -g tomcat tomcat
RUN chown -R tomcat:tomcat /opt/apache-tomcat

EXPOSE 8084

ENTRYPOINT ["/entrypoint.sh"]

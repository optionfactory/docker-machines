#!/bin/bash -e

chown -R tomcat:docker-machines /opt/apache-tomcat/webapps
exec gosu tomcat:docker-machines /opt/apache-tomcat/bin/catalina.sh run

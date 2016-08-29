#!/bin/bash -e

if [ $# -eq 0 ]; then
    chown -R tomcat:tomcat /opt/apache-tomcat/webapps
    exec /opt/apache-tomcat/bin/catalina.sh run
fi

exec "$@"

#!/bin/bash -e

if [ $# -eq 0 ]; then
    chown -R tomcat:docker-machine /opt/apache-tomcat/webapps
    exec gosu tomcat:docker-machine /opt/apache-tomcat/bin/catalina.sh run
fi

exec "$@"

#!/bin/bash -e

if [ $# -eq 0 ]; then
	exec /opt/apache-tomcat/bin/catalina.sh run
fi

exec "$@"
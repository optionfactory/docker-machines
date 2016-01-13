#!/bin/bash -e
. /etc/profile.d/log.sh

TOMCAT_MAJOR_VERSION=8
TOMCAT_VERSION=8.0.30
CATALINA_HOME=/opt/apache-tomcat

log "Downloading/Installing tomcat ${TOMCAT_VERSION}"
mkdir -p ${CATALINA_HOME}
curl -# -sSL -k https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz | tar xz -C ${CATALINA_HOME} --strip-components=1
rm -rf /opt/apache-tomcat/webapps/*
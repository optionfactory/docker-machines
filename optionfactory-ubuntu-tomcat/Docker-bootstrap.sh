#!/bin/bash -e
. /etc/profile.d/log.sh

TOMCAT_MAJOR_VERSION=8
TOMCAT_VERSION=8.0.30
CATALINA_HOME=/opt/apache-tomcat

log "Downloading/Installing tomcat ${TOMCAT_VERSION}"
mkdir -p ${CATALINA_HOME}
curl -# -sSL -k https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz | tar xz -C ${CATALINA_HOME} --strip-components=1
rm -rf /opt/apache-tomcat/webapps/*

gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && curl -Lo /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" \
    && curl -Lo /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" \
    && gpg --verify /usr/local/bin/gosu.asc \
    && rm /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu

#!/bin/bash -e

WILDFLY_VERSION=8.2.0.Final

echo "Downloading/Installing wildfly ${WILDFLY_VERSION}"
mkdir -p /opt/wildfly
curl http://download.jboss.org/wildfly/${WILDFLY_VERSION}/wildfly-${WILDFLY_VERSION}.tar.gz | tar xz -C /opt/wildfly --strip-components=1
chown -R wildfly:wildfly /opt/wildfly

echo "Removing unused features"
rm -rf /opt/wildfly/standalone/configuration/*
rm -rf /opt/wildfly/standalone/log
rm -rf /opt/wildfly/appclient
rm -rf /opt/wildfly/domain
rm -rf /opt/wildfly/docs
rm -rf /opt/wildfly/welcome-content


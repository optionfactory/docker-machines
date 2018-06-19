#!/bin/bash -e

JAVA_OPTS="-Xms64m -Xmx512m -Djava.net.preferIPv4Stack=true -Djboss.modules.system.pkgs=org.jboss.byteman -Djava.awt.headless=true"
# JPDA remote socket debugging
# JAVA_OPTS="$JAVA_OPTS -agentlib:jdwp=transport=dt_socket,address=8787,server=y,suspend=n"
# JBoss Modules metrics
# JAVA_OPTS="$JAVA_OPTS -Djboss.modules.metrics=true"

if [ $# -eq 0 ]; then
    for war in /opt/wildfly/standalone/deployments/*.war; do 
        touch "${war}.dodeploy"; 
    done    
    exec java \
        -D"[Standalone]" \
        ${JAVA_OPTS} \
        -Dlogging.configuration="file:/opt/wildfly/standalone/configuration/logging.properties" \
        -jar "/opt/wildfly/jboss-modules.jar" \
        -mp "/opt/wildfly/modules" org.jboss.as.standalone \
        -Djboss.home.dir="/opt/wildfly" \
        -Djboss.server.base.dir="/opt/wildfly/standalone" \
        -b 0.0.0.0
fi

exec "$@"



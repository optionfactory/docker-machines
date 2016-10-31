#!/bin/bash -e
chown -R alfresco:alfresco /opt/alfresco

CATALINA_HOME=/opt/alfresco/tomcat
TOMCAT_BINDIR=/opt/alfresco/tomcat/bin
JRE_HOME=/opt/alfresco/java

# merge AMPs
for ampfile in `find /opt/alfresco/amps/ -name '*.amp'`; do
    java -jar /opt/alfresco/bin/alfresco-mmt.jar install $ampfile $CATALINA_HOME/webapps/alfresco.war -nobackup;
done

for ampfile in `find /opt/alfresco/amps_share/ -name '*.amp'`; do
    java -jar /opt/alfresco/bin/alfresco-mmt.jar install $ampfile $CATALINA_HOME/webapps/share.war -nobackup;
done

# /opt/alfresco/postgresql/scripts/ctl.sh start

LOGDIR=/opt/alfresco/tomcat/logs/
cd $LOGDIR

exec gosu alfresco:alfresco sat \
    --prefix "[tomcat]" \
    --file "[alfresco] ":$LOGDIR/alfresco.log \
    --file "[solr] ":$LOGDIR/solr.log \
    --file "[share] ":$LOGDIR/share.log \
    -- \
    /opt/alfresco/tomcat/bin/catalina.sh run

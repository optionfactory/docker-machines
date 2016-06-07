#!/bin/bash -e

#export JAVA_HOME=/usr/java/latest

mkdir -p /opt/alfresco
cd /tmp
curl http://dl.alfresco.com/release/community/201604-build-00007/alfresco-community-installer-201604-linux-x64.bin -o /tmp/installer.bin
chmod +x /tmp/installer.bin
/tmp/installer.bin --mode unattended --prefix /opt/alfresco --alfresco_admin_password admin
rm /tmp/installer.bin

# add alfresco user
#useradd alfresco

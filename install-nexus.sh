#!/bin/bash -e

if [ -f /usr/bin/apt-get ] ; then
    DEBIAN_FRONTEND=noninteractive apt-get -y -q update
    DEBIAN_FRONTEND=noninteractive apt-get -y -q install createrepo
    DEBIAN_FRONTEND=noninteractive apt-get -y -q autoclean
    DEBIAN_FRONTEND=noninteractive apt-get -y -q autoremove
    rm -rf /var/lib/apt/lists/*
elif [ -f /usr/bin/zypper ] ; then
    zypper -n -q install createrepo 
    zypper -n -q clean --all
elif [ -f /usr/bin/yum ] ; then
    yum install -q -y curl createrepo
    yum clean all
else 
    echo "unknown or missing package manager"
    exit 1
fi


cp -r /tmp/nexus-* /opt/nexus/ 
groupadd -r nexus
useradd -r -m -g nexus -u 200 -d /opt/nexus/data nexus
chown -R nexus:nexus /opt/nexus
#!/bin/bash -e

echo "Installing builder"



groupadd --system --gid 950 builder
useradd --system --create-home --gid builder --uid 950 builder



mkdir -p /opt/apache-maven
cp -R /build/apache-maven*/* /opt/apache-maven
ln -s /opt/apache-maven/bin/mvn /usr/sbin/mvn

#

case "${DISTRIB_LABEL}" in
    debian*|ubuntu*)
        DEBIAN_FRONTEND=noninteractive apt-get -y -q update
        DEBIAN_FRONTEND=noninteractive apt-get -y -q install ansible make git rsync curl
        DEBIAN_FRONTEND=noninteractive apt-get -y -q autoclean
        DEBIAN_FRONTEND=noninteractive apt-get -y -q autoremove
        rm -rf /var/lib/apt/lists/* /etc/apt/sources.list.d/*
    ;;
    rocky9)
        yum install -q -y epel-release ansible-core make which git rsync
        yum clean all
        rm -rf /var/cache/yum
    ;;
    *)
    echo "distribution ${DISTRIB_LABEL} not supported"
    exit 1
    ;;
esac

#!/bin/bash -e

echo "Installing builder"



groupadd --system --gid 20000 docker-machines
useradd --system --create-home --gid docker-machines --uid 20007 builder

mkdir -p /opt/apache-maven
cp -R /tmp/apache-maven*/* /opt/apache-maven
ln -s /opt/apache-maven/bin/mvn /usr/sbin/mvn

#

case "${DISTRIB_LABEL}" in
    debian*|ubuntu*)
        DEBIAN_FRONTEND=noninteractive apt-get -y -q update
        DEBIAN_FRONTEND=noninteractive apt-get -y -q install ansible make
        DEBIAN_FRONTEND=noninteractive apt-get -y -q autoclean
        DEBIAN_FRONTEND=noninteractive apt-get -y -q autoremove
        rm -rf /var/lib/apt/lists/* /etc/apt/sources.list.d/nginx.list
    ;;
    centos8)
        yum install -q -y centos-release-ansible-29 make which
        yum clean all
        rm -rf /var/cache/yum
    ;;
    *)
    echo "distribution ${DISTRIB_LABEL} not supported"
    exit 1
    ;;
esac

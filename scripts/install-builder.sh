#!/bin/bash -e

echo "Installing builder"

groupadd --system --gid 950 docker-machines
useradd --system --create-home --gid docker-machines --uid 950 builder

mkdir -p /opt/apache-maven
cp -R /build/apache-maven*/* /opt/apache-maven
ln -s /opt/apache-maven/bin/mvn /usr/sbin/mvn

DEBIAN_FRONTEND=noninteractive apt-get -y -q update
DEBIAN_FRONTEND=noninteractive apt-get -y -q install ansible make git rsync curl
DEBIAN_FRONTEND=noninteractive apt-get -y -q autoclean
DEBIAN_FRONTEND=noninteractive apt-get -y -q autoremove
rm -rf /var/lib/apt/lists/* /etc/apt/sources.list.d/*

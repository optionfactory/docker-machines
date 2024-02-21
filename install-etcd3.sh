#!/bin/bash -e

echo "Installing etcd3"

groupadd --system --gid 20000 docker-machines
useradd --system --create-home --gid docker-machines --uid 20009 etcd


mkdir -p /opt/etcd3/{bin,conf,data}
cp -r /tmp/etcd-*-linux-amd64/etc* /opt/etcd3/bin/


chown -R etcd:docker-machines /opt/etcd3 

cp /tmp/init-etcd3.sh /etcd
chmod +x /etcd
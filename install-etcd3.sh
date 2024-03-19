#!/bin/bash -e

echo "Installing etcd3"

groupadd --system --gid 950 docker-machines
useradd --system --create-home --gid docker-machines --uid 950 etcd


mkdir -p /opt/etcd3/{bin,conf,data}
cp -r /build/etcd-*-linux-amd64/etc* /opt/etcd3/bin/


chown -R etcd:docker-machines /opt/etcd3 

cp /build/init-etcd3.sh /etcd
chmod +x /etcd
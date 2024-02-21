#!/bin/bash -e
chmod 770 /opt/etcd3/data
chown -R etcd:docker-machines /opt/etcd3/data
exec  gosu etcd:docker-machines /opt/etcd3/bin/etcd --data-dir /opt/etcd3/data "$@"

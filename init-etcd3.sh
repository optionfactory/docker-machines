#!/bin/bash -e

if [ $# -ne 0 ]; then
    exec "$@"
fi

exec /opt/etcd/etcd --config-file=/opt/etcd/conf/etcd.conf.yaml

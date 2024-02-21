#!/bin/bash -e
exec  gosu etcd:docker-machines /opt/etcd3/bin/etcd --data-dir /opt/etcd3/data "$@"

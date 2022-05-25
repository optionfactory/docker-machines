#!/bin/bash -e

exec /opt/etcd/etcd --config-file=/opt/etcd/conf/etcd.conf.yaml "$@"

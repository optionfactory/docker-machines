#!/bin/bash -e

if [ $# -ne 0 ]; then
    exec "$@"
fi

. /opt/etcd/conf/etcd.conf

exec /opt/etcd/etcd -data-dir=/opt/etcd/data \
    -name=${ETCD_NAME} \
    -listen-client-urls=${ETCD_LISTENT_CLIENT_URLS} \
    -listen-peer-urls=${ETCD_LISTEN_PEER_URLS} \
    -initial-cluster=${ETCD_INITIAL_CLUSTER} \
    -initial-advertise-peer-urls=${ETCD_INITIAL_ADVERTISE_PEER_URLS} \
    -advertise-client-urls=${ETCD_ADVERTISE_CLIENT_URLS}

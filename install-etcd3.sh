#!/bin/bash -e
echo "installing etcd2"


if [ -f /usr/bin/apt-get ]; then
    DEBIAN_FRONTEND=noninteractive apt-get -y -q update
    DEBIAN_FRONTEND=noninteractive apt-get -y -q --no-install-recommends install ca-certificates openssl tar
    DEBIAN_FRONTEND=noninteractive apt-get -y -q autoclean
    DEBIAN_FRONTEND=noninteractive apt-get -y -q autoremove
    rm -rf /var/lib/apt/lists/*
elif [ -f /usr/bin/zypper ] ; then
    zypper -n -q install ca-certificates openssl tar
    zypper -n -q clean --all
elif [ -f /usr/bin/yum ] ; then
    yum install -q -y ca-certificates openssl tar
    yum clean all
    rm -rf /var/cache/yum
else
    echo "unknown or missing package manager"
    exit 1
fi

cp -r /tmp/etcd* /opt/etcd/
mkdir -p /opt/etcd/data/
mkdir -p /opt/etcd/conf/


cat <<-'EOF' > /opt/etcd/conf/etcd.conf
    ETCD_NAME=standalone
    ETCD_LISTENT_CLIENT_URLS=https://0.0.0.0:2379
    ETCD_LISTEN_PEER_URLS=https://0.0.0.0:2380
    ETCD_INITIAL_CLUSTER=standalone=https://172.17.0.1:2380
    ETCD_INITIAL_ADVERTISE_PEER_URLS=https://172.17.0.1:2380
    ETCD_ADVERTISE_CLIENT_URLS=https://172.17.0.1:2380
    ETCD_KEY_FILE=/opt/etcd/conf/key.pem
    ETCD_CERT_FILE=/opt/etcd/conf/cert.pem
EOF

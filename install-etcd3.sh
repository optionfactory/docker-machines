#!/bin/bash -e
echo "installing etcd3"


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


cat <<-'EOF' > /opt/etcd/conf/etcd.conf.yaml
    name: standalone
    data-dir: /opt/etcd/data/
    listen-client-urls: https://0.0.0.0:2379
    listen-peer-urls: https://0.0.0.0:2380
    initial-cluster: standalone=https://172.17.0.1:2380
    initial-advertise-peer-urls: https://172.17.0.1:2380
    advertise-client-urls: https://172.17.0.1:2380
    client-transport-security:
        key-file: /opt/etcd/conf/certs/clients-key.pem
        cert-file: /opt/etcd/conf/certs/clients-cert.pem
        trusted-ca-file: /opt/etcd/conf/certs/trusted-ca-cert.pem
        client-cert-auth: true
    peer-transport-security:
        key-file: /opt/etcd/conf/certs/peers-key.pem
        cert-file: /opt/etcd/conf/certs/peers-cert.pem
        trusted-ca-file: /opt/etcd/conf/certs/trusted-ca-cert.pem
        client-cert-auth: true
EOF

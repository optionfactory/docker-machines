#!/bin/bash -e

echo "Installing etcd3"

groupadd --system --gid 950 docker-machines
useradd --system --create-home --gid docker-machines --uid 950 etcd


mkdir -p /opt/etcd3/{bin,conf,data}
cp -r /build/etcd-*-linux-amd64/etc* /opt/etcd3/bin/


chown -R etcd:docker-machines /opt/etcd3 

cat <<'EOF' > /etcd
#!/bin/bash -e
chmod 770 /opt/etcd3/data
chown -R etcd:docker-machines /opt/etcd3/data
exec  gosu etcd:docker-machines /opt/etcd3/bin/etcd --data-dir /opt/etcd3/data "$@"
EOF

chmod 750 /etcd



#!/bin/bash -e

echo "Installing nginx exporter"

groupadd --system --gid 950 docker-machines
useradd --system --create-home --gid docker-machines --uid 950 monitoring

mkdir -p /opt/nginx-exporter/{bin,conf}

cp -r /build/nginx-exporter-* /opt/nginx-exporter/bin/nginx-exporter

cat <<'EOF' > /monitoring-nginx
#!/bin/bash -e
exec setpriv --reuid=monitoring --regid=docker-machines --init-groups -- /opt/nginx-exporter/bin/nginx-exporter "$@"
EOF

chown -R monitoring:docker-machines /opt/nginx-exporter
find /opt/nginx-exporter -type f -exec chmod 600 {} \;
find /opt/nginx-exporter -type d -exec chmod 700 {} \;
chmod 700 /opt/nginx-exporter/bin/nginx-exporter
chmod 700 /monitoring-nginx



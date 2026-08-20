#!/bin/bash -e

echo "Installing postgres exporter"

groupadd --system --gid 950 docker-machines
useradd --system --create-home --gid docker-machines --uid 950 monitoring

mkdir -p /opt/postgres-exporter/{bin,conf}/

cp -r /build/postgres-exporter-*-linux-amd64 /opt/postgres-exporter/bin/postgres-exporter

cat <<'EOF' > /opt/postgres-exporter/conf/postgres-exporter.yml
auth_modules: {}
EOF


cat <<'EOF' > /monitoring-postgres
#!/bin/bash -e
exec setpriv --reuid=monitoring --regid=docker-machines --init-groups -- /opt/postgres-exporter/bin/postgres-exporter --config.file /opt/postgres-exporter/conf/postgres-exporter.yml "$@"
EOF

chown -R monitoring:docker-machines /opt/postgres-exporter
find /opt/postgres-exporter -type f -exec chmod 600 {} \;
find /opt/postgres-exporter -type d -exec chmod 700 {} \;
chmod 700 /opt/postgres-exporter/bin/postgres-exporter
chmod 700 /monitoring-postgres



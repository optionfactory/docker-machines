#!/bin/bash -e

echo "Installing postgres exporter"

mkdir -p /opt/postgres-exporter/{bin,conf}/

cp -r /build/postgres-exporter-*-linux-amd64 /opt/postgres-exporter/bin/postgres-exporter

cat <<'EOF' > /opt/postgres-exporter/conf/postgres-exporter.yml
auth_modules: {}
EOF


cat <<'EOF' > /monitoring-postgres
#!/bin/bash -e
exec /opt/postgres-exporter/bin/postgres-exporter --config.file /opt/postgres-exporter/conf/postgres-exporter.yml "$@"
EOF

chmod 750 /opt/postgres-exporter/bin/postgres-exporter 
chmod 750 /monitoring-postgres



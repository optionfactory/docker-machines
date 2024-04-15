#!/bin/bash -e

echo "Installing node exporter"

mkdir -p /opt/node-exporter/{bin,conf}/

cp -r /build/node-exporter-*-linux-amd64 /opt/node-exporter/bin/node-exporter


cat <<'EOF' > /monitoring-host
#!/bin/bash -e
exec /opt/node-exporter/bin/node-exporter "$@"
EOF

chmod 750 /opt/node-exporter/bin/node-exporter 
chmod 750 /monitoring-host



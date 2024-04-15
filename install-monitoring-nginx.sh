#!/bin/bash -e

echo "Installing nginx exporter"

mkdir -p /opt/nginx-exporter/{bin,conf}

cp -r /build/nginx-exporter-* /opt/nginx-exporter/bin/nginx-exporter

cat <<'EOF' > /monitoring-nginx
#!/bin/bash -e
/opt/nginx-exporter/bin/nginx-exporter "$@"
EOF

chmod 750 /opt/nginx-exporter/bin/nginx-exporter
chmod 750 /monitoring-nginx



#!/bin/bash -e

echo "Installing cadvisor"

mkdir -p /opt/cadvisor/bin

cp -r /build/cadvisor-*-linux-amd64 /opt/cadvisor/bin/cadvisor

cat <<'EOF' > /monitoring-cadvisor
#!/bin/bash -e
exec /opt/cadvisor/bin/cadvisor -logtostderr "$@"
EOF

chmod 750 /opt/cadvisor/bin/cadvisor 
chmod 750 /monitoring-cadvisor



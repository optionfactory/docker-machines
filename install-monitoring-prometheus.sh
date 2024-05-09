#!/bin/bash -e

echo "Installing prometheus"

mkdir -p /opt/prometheus/{bin,conf,data,consoles,console-libs}
chmod 750 /opt/prometheus/{bin,conf,data,consoles,console-libs}

cp /build/prometheus-*/prometheus /opt/prometheus/bin/prometheus
cp /build/prometheus-*/promtool /opt/prometheus/bin/promtool
cp -r /build/prometheus-*/consoles/* /opt/prometheus/consoles
cp -r /build/prometheus-*/console_libraries/* /opt/prometheus/console-libs

cat <<'EOF' > /opt/prometheus/conf/prometheus.yml
global:
  scrape_interval: 15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
EOF

cat <<'EOF' > /prometheus
#!/bin/bash -e
exec /opt/prometheus/bin/prometheus \
    --config.file=/opt/prometheus/conf/prometheus.yml \
    --storage.tsdb.path=/opt/prometheus/data/ \
    --web.console.libraries=/opt/prometheus/console-libs \
    --web.console.templates=/usr/prometheus/consoles \
    "$@"
EOF

chmod 750 /prometheus



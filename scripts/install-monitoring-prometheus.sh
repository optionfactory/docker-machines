#!/bin/bash -e

echo "Installing prometheus"

groupadd --system --gid 950 docker-machines
useradd --system --create-home --gid docker-machines --uid 950 monitoring

mkdir -p /opt/prometheus/{bin,conf,data,consoles,console-libs}

cp /build/prometheus-*/prometheus /opt/prometheus/bin/prometheus
cp /build/prometheus-*/promtool /opt/prometheus/bin/promtool
mkdir -p /opt/prometheus/consoles
mkdir -p /opt/prometheus/console-libs

cat <<'EOF' > /opt/prometheus/conf/prometheus.yml
global:
  scrape_interval: 15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
EOF

cat <<'EOF' > /prometheus
#!/bin/bash -e
exec setpriv --reuid=monitoring --regid=docker-machines --init-groups -- /opt/prometheus/bin/prometheus \
    --config.file=/opt/prometheus/conf/prometheus.yml \
    --storage.tsdb.path=/opt/prometheus/data/ \
    --web.console.libraries=/opt/prometheus/console-libs \
    --web.console.templates=/opt/prometheus/consoles \
    "$@"
EOF

chown -R monitoring:docker-machines /opt/prometheus
find /opt/prometheus -type f -exec chmod 600 {} \;
find /opt/prometheus -type d -exec chmod 700 {} \;
chmod 700 /opt/prometheus/bin/prometheus
chmod 700 /opt/prometheus/bin/promtool
chmod 700 /prometheus



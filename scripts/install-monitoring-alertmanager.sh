#!/bin/bash -e

echo "Installing alertmanager"

groupadd --system --gid 950 docker-machines
useradd --system --create-home --gid docker-machines --uid 950 monitoring

mkdir -p /opt/alertmanager/{bin,conf,data}

cp /build/alertmanager-*/alertmanager /opt/alertmanager/bin/alertmanager
cp /build/alertmanager-*/amtool /opt/alertmanager/bin/amtool

cat <<'EOF' > /opt/alertmanager/conf/alertmanager.yml
route:
  group_by: ['alertname']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 1h
  receiver: 'default'
receivers:
  - name: 'default'
EOF

cat <<'EOF' > /alertmanager
#!/bin/bash -e
exec setpriv --reuid=monitoring --regid=docker-machines --init-groups -- /opt/alertmanager/bin/alertmanager \
  --config.file=/opt/alertmanager/conf/alertmanager.yml \
  --storage.path=/opt/alertmanager/data/ \
  "$@"
EOF

chown -R monitoring:docker-machines /opt/alertmanager
find /opt/alertmanager -type f -exec chmod 600 {} \;
find /opt/alertmanager -type d -exec chmod 700 {} \;
chmod 700 /opt/alertmanager/bin/alertmanager
chmod 700 /opt/alertmanager/bin/amtool
chmod 700 /alertmanager



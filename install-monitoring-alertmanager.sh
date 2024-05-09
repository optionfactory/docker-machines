#!/bin/bash -e

echo "Installing alertmanager"

mkdir -p /opt/alertmanager/{bin,conf,data}
chmod 750 /opt/alertmanager/{bin,conf,data}

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
exec /opt/alertmanager/bin/alertmanager \
  --config.file=/opt/alertmanager/conf/alertmanager.yml \
  --storage.path=/opt/alertmanager/data/ \
  "$@"
EOF

chmod 750 /alertmanager



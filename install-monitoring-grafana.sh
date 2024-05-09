#!/bin/bash -e

echo "Installing grafana"

groupadd --system --gid 950 docker-machines
useradd --system --create-home --gid docker-machines --uid 950 grafana

mkdir -p /opt/grafana/{bin,conf,data,plugins,plugins-bundled,public}
mkdir -p /opt/grafana/provisioning/{datasources,plugins,notifiers,alerting,dashboards}

cp -R /build/grafana-*/public/* /opt/grafana/public/
cp /build/grafana-*/bin/grafana /opt/grafana/bin/
cp /build/grafana-*/conf/defaults.ini /opt/grafana/conf/

cat <<'EOF' >> /opt/grafana/conf/defaults.ini
#################################### docker optionfactory overrides ####################################
[paths]
data = data
plugins = plugins
provisioning = provisioning

[server]
domain = 172.17.0.1

[analytics]
reporting_enabled = false
check_for_updates = false
check_for_plugin_updates = false

[log]
mode = console

[dataproxy]
logging = true

[plugins]
public_key_retrieval_disabled = true
plugin_admin_enabled = false

[news]
news_feed_enabled = false

[help]
enabled = false

[profile]
enabled = false
EOF

touch /opt/grafana/conf/grafana.ini

cat <<'EOF' > /grafana
#!/bin/bash -e
exec gosu grafana:docker-machines /opt/grafana/bin/grafana server \
  --homepath /opt/grafana/ \
  --config /opt/grafana/conf/grafana.ini \
  "$@"
EOF

chown -R grafana:docker-machines /opt/grafana
find /opt/grafana -type f -exec chmod 600 {} \;
find /opt/grafana -type d -exec chmod 700 {} \;
chmod 700 /opt/grafana/bin/grafana
chmod 700 /grafana



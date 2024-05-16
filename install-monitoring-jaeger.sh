#!/bin/bash -e

echo "Installing jaeger"

mkdir -p /opt/jaeger/{bin,conf,data}
chmod 750 /opt/jaeger/{bin,conf,data}

cp /build/jaeger-*/* /opt/jaeger/bin/

cat <<'EOF' > /opt/jaeger/conf/jaeger.yml

EOF

cat <<'EOF' > /opt/jaeger/conf/jaeger-ui.json
{
    
}
EOF


cat <<'EOF' > /jaeger
#!/bin/bash -e
exec /opt/jaeger/bin/jaeger-all-in-one \
  --config-file /opt/jaeger/conf/jaeger.yml \
  --query.ui-config /opt/jaeger/conf/jaeger-ui.json \
  "$@"
EOF

chmod 750 /jaeger



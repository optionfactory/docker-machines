#!/bin/bash -e

echo "Installing tempo"

groupadd --system --gid 950 docker-machines
useradd --system --create-home --gid docker-machines --uid 950 tempo

mkdir -p /opt/tempo/{bin,conf,data,wal,blocks}

cp /build/tempo-*/tempo* /opt/tempo/bin/

cat <<'EOF' >> /opt/tempo/conf/tempo.yml
server:
  http_listen_port: 3200
distributor:
  receivers:
    otlp:
      protocols:
        http:
        grpc:
storage:
  trace:
    backend: local
    wal:
      path: /opt/tempo/wal
    local:
      path: /opt/tempo/blocks
EOF


cat <<'EOF' > /tempo
#!/bin/bash -e
exec gosu tempo:docker-machines /opt/tempo/bin/tempo -config.file /opt/tempo/conf/tempo.yml "$@"
EOF

chown -R tempo:docker-machines /opt/tempo
find /opt/tempo -type f -exec chmod 600 {} \;
find /opt/tempo -type d -exec chmod 700 {} \;
chmod 700 /opt/tempo/bin/tempo
chmod 700 /tempo



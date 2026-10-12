#!/bin/bash -e

echo "Installing livekit"

groupadd --system --gid 950 docker-machines
useradd --system --create-home --gid docker-machines --uid 950 livekit

mkdir -p /opt/livekit/{bin,conf}
cp /build/livekit-server-* /opt/livekit/bin/livekit-server

chown -R livekit:docker-machines /opt/livekit
chmod 750 /opt/livekit/bin/livekit-server

cat <<'EOS' > /livekit
#!/bin/bash -e
exec setpriv --reuid=livekit --regid=docker-machines --init-groups --no-new-privs -- /opt/livekit/bin/livekit-server --config /opt/livekit/conf/livekit.yaml "$@"
EOS

chmod 750 /livekit

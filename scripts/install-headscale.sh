#!/bin/bash -e

echo "Installing headscale"

groupadd --system --gid 950 docker-machines
useradd --system --create-home --gid docker-machines --uid 950 headscale

mkdir -p /opt/headscale/{bin,conf,data,run}
cp /build/headscale-* /opt/headscale/bin/headscale

chown -R headscale:docker-machines /opt/headscale
chmod 750 /opt/headscale/bin/headscale

# the cli talks to the server over /opt/headscale/run/headscale.sock (unix_socket in config.yaml):
# `docker exec headscale headscale nodes list`
cat <<'EOS' > /usr/local/bin/headscale
#!/bin/bash -e
exec setpriv --reuid=headscale --regid=docker-machines --init-groups --no-new-privs -- /opt/headscale/bin/headscale --config /opt/headscale/conf/config.yaml "$@"
EOS

cat <<'EOS' > /headscale
#!/bin/bash -e
exec /usr/local/bin/headscale serve "$@"
EOS

chmod 755 /usr/local/bin/headscale
chmod 750 /headscale

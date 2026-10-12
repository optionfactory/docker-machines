#!/bin/bash -e

echo "Installing tuwunel"

groupadd --system --gid 950 docker-machines
useradd --system --create-home --gid docker-machines --uid 950 tuwunel

mkdir -p /opt/tuwunel/{bin,conf,data}
cp /build/tuwunel-* /opt/tuwunel/bin/tuwunel

chown -R tuwunel:docker-machines /opt/tuwunel
chmod 750 /opt/tuwunel/bin/tuwunel

cat <<'EOS' > /tuwunel
#!/bin/bash -e
export TUWUNEL_CONFIG=/opt/tuwunel/conf/tuwunel.toml
exec setpriv --reuid=tuwunel --regid=docker-machines --init-groups --no-new-privs -- /opt/tuwunel/bin/tuwunel "$@"
EOS

chmod 750 /tuwunel

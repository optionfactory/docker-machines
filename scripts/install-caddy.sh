#!/bin/bash -e

echo "Installing Caddy"

groupadd --system --gid 950 docker-machines
useradd --system --create-home --gid docker-machines --uid 950 caddy

mkdir -p /opt/caddy/{bin,conf,data}
cp /build/caddy-* /opt/caddy/bin/caddy



cat <<'EOF' > /opt/caddy/conf/caddy.conf.json
    {
        "admin": {
            "disabled": true
        },
        "apps": {
            "http": {
                "servers": {
                    "all": {
                        "listen": [":80"]
                    }
                }
            }
        }        
    }
EOF



chown -R caddy:docker-machines /opt/caddy

cat <<'EOF' > /caddy
#!/bin/bash -e

# podman, unlike docker, does not set net.ipv4.ip_unprivileged_port_start=0 in the container:
# keep only net_bind_service, as an ambient capability (no_new_privs blocks file capabilities)
XDG_DATA_HOME=/opt/caddy/data/ exec setpriv --reuid=caddy --regid=docker-machines --init-groups --no-new-privs --inh-caps=-all,+net_bind_service --ambient-caps=+net_bind_service --bounding-set=-all,+net_bind_service -- /opt/caddy/bin/caddy run --config /opt/caddy/conf/caddy.conf.json
EOF

chmod 750 /caddy

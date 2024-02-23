#!/bin/bash -e

echo "Installing Caddy"

groupadd --system --gid 20000 docker-machines
useradd --system --create-home --gid docker-machines --uid 20009 caddy


case "${DISTRIB_LABEL}" in
    debian*|ubuntu*)
        DEBIAN_FRONTEND=noninteractive apt-get -y -q update
        DEBIAN_FRONTEND=noninteractive apt-get -y -q install libcap2-bin
        DEBIAN_FRONTEND=noninteractive apt-get -y -q autoclean
        DEBIAN_FRONTEND=noninteractive apt-get -y -q autoremove
        rm -rf /var/lib/apt/lists/* /etc/apt/sources.list.d/*
    ;;
    rocky9)
    ;;
    *)
    echo "distribution ${DISTRIB_LABEL} not supported"
    exit 1
    ;;
esac



mkdir -p /opt/caddy/{bin,conf,data}
cp /tmp/caddy-* /opt/caddy/bin/caddy
setcap cap_net_bind_service=+ep /opt/caddy/bin/caddy



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
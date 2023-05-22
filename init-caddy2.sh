#!/bin/bash -e

XDG_DATA_HOME=/opt/caddy/data/ exec gosu caddy:docker-machines /opt/caddy/bin/caddy run --config /opt/caddy/conf/caddy.conf.json
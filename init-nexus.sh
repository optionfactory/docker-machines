#!/bin/bash -e

if [ $# -eq 0 ]; then
    chown -R nexus:nexus /opt/nexus/data
    exec /opt/nexus/bin/nexus run
fi

exec "$@"

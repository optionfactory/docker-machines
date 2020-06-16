#!/bin/bash -e

if [ $# -eq 0 ]; then
    chown -R keycloak:docker-machines /opt/keycloak
    exec gosu keycloak:docker-machines /opt/keycloak/bin/standalone.sh
fi

exec "$@"

#!/bin/bash -e

if [ $# -eq 0 ]; then
    chown -R keycloak:keycloak /opt/keycloak
    exec gosu keycloak:keycloak /opt/keycloak/bin/standalone.sh
fi

exec "$@"

#!/bin/bash -e

if [ $# -eq 0 ]; then
    chown -R keycloak:docker-machines /opt/keycloak
    exec gosu keycloak:docker-machines /opt/keycloak/bin/kc.sh start --auto-build
fi
if [ $# -eq 1 ] && [ "${1}" == "dev" ]; then
    chown -R keycloak:docker-machines /opt/keycloak
    exec gosu keycloak:docker-machines /opt/keycloak/bin/kc.sh start-dev
fi


exec "$@"

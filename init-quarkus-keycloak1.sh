#!/bin/bash -e

chown -R keycloak:docker-machines /opt/keycloak
exec gosu keycloak:docker-machines /opt/keycloak/bin/kc.sh start "$@"

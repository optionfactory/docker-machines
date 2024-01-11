#!/bin/bash -e

echo "Installing Keycloak"
mkdir -p /opt/keycloak
cp -R /tmp/keycloak*/* /opt/keycloak
cp -R /tmp/optionfactory-keycloak-*/* /opt/keycloak/providers/

cat <<-'EOF' > /opt/keycloak/conf/keycloak.conf
#[build options]
cache=local
db=postgres
transaction-xa-enabled=true
#features=
http-relative-path=/
health-enabled=false
metrics-enabled=false

#[runtime options]
db-url=jdbc:postgresql://172.17.0.1/keycloak
db-username=postgres
db-password=

log=console
log-console-color=false
log-console-format=[%d{yyyy-MM-dd HH:mm:ss,SSSz}][%-5p][%c{3.}] (%t) %s%e%n

http-port=8080
proxy=edge
hostname-strict=false


#[email-sender-provider:opfa-cid-embedding]
#spi-email-sender-provider=opfa-cid-embedding

#[events-listener:opfa-login-stats]
#spi-events-listener-opfa-login-stats-attribute=loginStats

#[theme-welcome-theme:opfablank]
spi-theme-welcome-theme=opfablank

EOF

groupadd --system --gid 20000 docker-machines
useradd --system --create-home --gid docker-machines --uid 20001 keycloak
chown -R keycloak:docker-machines /opt/keycloak

/opt/keycloak/bin/kc.sh build 
/opt/keycloak/bin/kc.sh show-config
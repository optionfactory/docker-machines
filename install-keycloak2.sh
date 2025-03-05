#!/bin/bash -e

echo "Installing Keycloak"
mkdir -p /opt/keycloak
cp -R /build/keycloak*/* /opt/keycloak
cp -R /build/optionfactory-keycloak-*/* /opt/keycloak/providers/
cp -R /opt/keycloak/lib/lib/deployment/jakarta.validation.jakarta.validation-api-*.jar /opt/keycloak/providers/
cat <<-'EOF' > /opt/keycloak/conf/keycloak.conf
#[build options]
cache=local
db=postgres
transaction-xa-enabled=true
#features=
http-relative-path=/
health-enabled=true
metrics-enabled=true

#[runtime options]
db-url=jdbc:postgresql://172.17.0.1/keycloak
db-username=postgres
db-password=

log=console
log-console-format=[%d{yyyy-MM-dd HH:mm:ss,SSSz}][%-5p][%c{3.}] (%t) %s%e%n

#proxy-headers=xforwarded
http-port=8080
hostname-strict=false

#[email-sender-provider:opfa-cid-embedding]
#spi-email-sender-provider=opfa-cid-embedding

#[events-listener:opfa-login-stats]
#spi-events-listener-opfa-login-stats-attribute=loginStats

#[theme-welcome-theme:opfablank]
spi-theme-welcome-theme=opfablank

EOF

groupadd --system --gid 950 docker-machines
useradd --system --create-home --gid docker-machines --uid 950 keycloak
chown -R keycloak:docker-machines /opt/keycloak

/opt/keycloak/bin/kc.sh build 
/opt/keycloak/bin/kc.sh show-config


cat <<'EOF' > /keycloak
#!/bin/bash -e
chown -R keycloak:docker-machines /opt/keycloak
exec gosu keycloak:docker-machines /opt/keycloak/bin/kc.sh start "$@"
EOF

chmod 750 /keycloak

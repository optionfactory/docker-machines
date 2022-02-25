#!/bin/bash -e

echo "Installing Keycloak"
mkdir -p /opt/keycloak
cp -R /tmp/keycloak*/* /opt/keycloak

cat <<-'EOF' > /opt/keycloak/conf/keycloak.properties
db=postgres
db.url=jdbc:postgresql://172.17.0.1/keycloakx
db.username=postgres
db.password=
cache=local
metrics.enabled=false

http.relative-path=/auth

http.port=8888

proxy=edge
hostname.strict=false
hostname.strict-https=false

%dev.proxy=none
%dev.hostname.strict=false
%dev.hostname.strict-https=false

#spi.hostname.frontend-url=https://172.17.0.1:8443

%import_export.http.enabled=true
%import_export.hostname.strict=false
%import_export.hostname.strict-https=false
%import_export.cluster=local
quarkus.log.console.color=false
quarkus.log.console.format=[%d{yyyy-MM-dd HH:mm:ss,SSSz}][%-5p][%c{3.}] (%t) %s%e%n
quarkus.log.category."org.jboss.resteasy.resteasy_jaxrs.i18n".level=WARN
quarkus.log.category."org.infinispan.transaction.lookup.JBossStandaloneJTAManagerLookup".level=WARN

EOF

groupadd --system --gid 20000 docker-machines
useradd --system --create-home --gid docker-machines --uid 20001 keycloak
chown -R keycloak:docker-machines /opt/keycloak

/opt/keycloak/bin/kc.sh build 
/opt/keycloak/bin/kc.sh show-config
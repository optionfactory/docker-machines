#!/bin/bash -e

echo "Installing vaultwarden"

groupadd --system --gid 950 docker-machines
useradd --system --create-home --gid docker-machines --uid 950 vaultwarden

mkdir -p /opt/vaultwarden/{bin,data}
# binary and web vault come from the same upstream image, so they always match
cp /build/vaultwarden-* /opt/vaultwarden/bin/vaultwarden
cp -r /build/web-vault /opt/vaultwarden/web-vault

chown -R vaultwarden:docker-machines /opt/vaultwarden
chmod 750 /opt/vaultwarden/bin/vaultwarden

cat <<'EOS' > /vaultwarden
#!/bin/bash -e
cd /opt/vaultwarden
export DATA_FOLDER=/opt/vaultwarden/data
export WEB_VAULT_FOLDER=/opt/vaultwarden/web-vault
export ROCKET_ADDRESS=${ROCKET_ADDRESS:-0.0.0.0}
export ROCKET_PORT=${ROCKET_PORT:-8080}
exec setpriv --reuid=vaultwarden --regid=docker-machines --init-groups --no-new-privs -- /opt/vaultwarden/bin/vaultwarden "$@"
EOS

chmod 750 /vaultwarden

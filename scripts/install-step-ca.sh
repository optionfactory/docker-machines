#!/bin/bash -e

echo "Installing step-ca"

groupadd --system --gid 950 docker-machines
useradd --system --create-home --gid docker-machines --uid 950 step-ca

# STEPPATH: config/ca.json, certs, secrets (keys and their password), db
mkdir -p /opt/step-ca/{bin,data}
cp /build/step-ca /build/step /opt/step-ca/bin/

chown -R step-ca:docker-machines /opt/step-ca
chmod 750 /opt/step-ca/bin/step-ca /opt/step-ca/bin/step

# the cli, as the service user on the same STEPPATH: `docker exec step-ca step ca provisioner list`,
# `docker run --rm --entrypoint step ... ca init ...`
cat <<'EOF' > /usr/local/bin/step
#!/bin/bash -e
export STEPPATH=/opt/step-ca/data
exec setpriv --reuid=step-ca --regid=docker-machines --init-groups --no-new-privs -- /opt/step-ca/bin/step "$@"
EOF

cat <<'EOF' > /step-ca
#!/bin/bash -e
export STEPPATH=/opt/step-ca/data
exec setpriv --reuid=step-ca --regid=docker-machines --init-groups --no-new-privs -- /opt/step-ca/bin/step-ca \
    "${STEPPATH}/config/ca.json" --password-file "${STEPPATH}/secrets/password" "$@"
EOF

chmod 755 /usr/local/bin/step
chmod 750 /step-ca

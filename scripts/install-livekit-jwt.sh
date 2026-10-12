#!/bin/bash -e

echo "Installing livekit-jwt (lk-jwt-service)"

groupadd --system --gid 950 docker-machines
useradd --system --create-home --gid docker-machines --uid 950 livekit-jwt

mkdir -p /opt/livekit-jwt/bin
cp /build/lk-jwt-service-* /opt/livekit-jwt/bin/lk-jwt-service

chown -R livekit-jwt:docker-machines /opt/livekit-jwt
chmod 750 /opt/livekit-jwt/bin/lk-jwt-service

# configured through LIVEKIT_* environment variables
cat <<'EOS' > /livekit-jwt
#!/bin/bash -e
exec setpriv --reuid=livekit-jwt --regid=docker-machines --init-groups --no-new-privs -- /opt/livekit-jwt/bin/lk-jwt-service "$@"
EOS

chmod 750 /livekit-jwt

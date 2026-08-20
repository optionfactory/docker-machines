#!/bin/bash -e

echo "Installing nginx ${NGINX_MAJOR_VERSION}"
groupadd --system --gid 950 docker-machines
useradd --system --create-home --gid docker-machines --uid 950 nginx

DEBIAN_FRONTEND=noninteractive apt-get -y -q update
DEBIAN_FRONTEND=noninteractive apt-get -y -q install curl

install -d -m 0755 /etc/apt/keyrings
curl -# -L https://nginx.org/keys/nginx_signing.key > /etc/apt/keyrings/nginx.asc
echo "deb [signed-by=/etc/apt/keyrings/nginx.asc] https://nginx.org/packages/${DISTRIB_ID}/ ${DISTRIB_CODENAME} nginx" >> /etc/apt/sources.list.d/nginx.list

DEBIAN_FRONTEND=noninteractive apt-get -y -q update
DEBIAN_FRONTEND=noninteractive apt-get -y -q install --no-install-recommends --no-install-suggests nginx=${NGINX_MAJOR_VERSION}.* nginx-module-acme=${NGINX_MAJOR_VERSION}.* gettext-base

rm -rf /var/lib/apt/lists/* /etc/apt/sources.list.d/nginx.list

cat <<'EOF' > /etc/nginx/nginx.conf

load_module modules/opfa_http_remove_server_header_module.so;

user  nginx;
worker_processes  1;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;

events {
    worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format main '[ts:${time_iso8601}]'
                    '[remote:${remote_user}@${remote_addr}]'
                    '[elapsed:${request_time}s]'
                    '[upstream:${upstream_connect_time}s,${upstream_header_time}s,${upstream_response_time}s]'
                    '[response:${status},${body_bytes_sent}b,${bytes_sent}b]'
                    '[method:${request_method}][proto:${server_protocol}][len:${request_length}b][referer:"$http_referer"][ua:"$http_user_agent"] uri:"${request_uri}"';

    access_log  /var/log/nginx/access.log main;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;

}
EOF

cat <<'EOF' > /etc/nginx/error_pages.conf
error_page 301 302 303 307 308 400 401 402 403 404 405 406 408 409 410 411 412 413 414 415 416 421 429 494 495 496 497 500 501 502 503 504 505 507 /internal_custom_error;

location /internal_custom_error {
    internal;
    etag off;
    alias empty_body;
}
EOF

cat <<'EOF' > /etc/nginx/forwarded.conf
    # edge proxy
    # headers
    proxy_set_header Host              $http_host;
    proxy_set_header X-Real-IP         $remote_addr;
    proxy_set_header X-Forwarded-For   $remote_addr;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-Host  $http_host;
    proxy_set_header X-Forwarded-Port  $server_port;
    proxy_set_header X-Forwarded-Server $host;

    # Tracing & Custom Headers
    proxy_set_header X-RID          $request_id;
    proxy_set_header X-Scheme       $scheme;
    proxy_set_header X-Original-URI $request_uri;

    # websockets / HTTP upgrade (Requires 'map $http_upgrade $connection_upgrade' in http block)
    proxy_set_header Upgrade        $http_upgrade;
    proxy_set_header Connection     $connection_upgrade;

    # timeouts
    proxy_send_timeout 300s;
    proxy_read_timeout 300s;

    # buffers
    proxy_buffer_size          128k;
    proxy_buffers              4 256k;
    proxy_busy_buffers_size    256k;

EOF

cat <<'EOF' > /etc/nginx/reforwarded.conf
    # internal proxy 
    # headers
    proxy_set_header Host              $http_host;
    proxy_set_header X-Real-IP $http_x_real_ip;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $http_x_forwarded_proto;
    proxy_set_header X-Forwarded-Host  $http_host;
    proxy_set_header X-Forwarded-Port $http_x_forwarded_port;
    proxy_set_header X-Forwarded-Server $host;

    # Tracing & Custom Headers
    proxy_set_header X-RID          $request_id;
    proxy_set_header X-Scheme       $scheme;
    proxy_set_header X-Original-URI $request_uri;

    # websockets / HTTP upgrade (Requires 'map $http_upgrade $connection_upgrade' in http block)
    proxy_set_header Upgrade        $http_upgrade;
    proxy_set_header Connection     $connection_upgrade;

    # timeouts
    proxy_send_timeout 300s;
    proxy_read_timeout 300s;

    # buffers
    proxy_buffer_size          128k;
    proxy_buffers              4 256k;
    proxy_busy_buffers_size    256k;
EOF

cat <<'EOF' > /etc/nginx/hsts.conf
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
EOF

cat <<'EOF' > /etc/nginx/tls-modern.conf
    ssl_protocols TLSv1.3;
    ssl_ecdh_curve X25519MLKEM768:X25519:prime256v1:secp384r1;
    ssl_prefer_server_ciphers off;
EOF


cat <<'EOF' > /etc/nginx/tls-intermediate.conf
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ecdh_curve X25519MLKEM768:X25519:prime256v1:secp384r1;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305;
    ssl_prefer_server_ciphers off;

    ssl_session_tickets off;
    ssl_session_timeout 1d;
    ssl_session_cache shared:MozSSL:10m;  # about 40000 sessions
EOF

ln -sf /dev/stdout /var/log/nginx/access.log
ln -sf /dev/stderr /var/log/nginx/error.log

rm -rf /etc/nginx/{conf.d,modules}
mkdir -p /etc/nginx/{modules,certificates}/

touch /etc/nginx/empty_body
cp /build/opfa_http_remove_server_header_module-*.so /etc/nginx/modules/opfa_http_remove_server_header_module.so
cp /build/legopfa-* /usr/bin/legopfa

cat <<'EOF' > /legopfa-all
#!/bin/bash -e
find /etc/nginx/certificates/ -maxdepth 1 -name '*.json' -exec legopfa {} ";"
EOF

chmod 750 /legopfa-all

cat <<'EOF' > /nginx
#!/bin/bash -e
/legopfa-all
exec nginx -g "daemon off;"
EOF

chmod 750 /nginx

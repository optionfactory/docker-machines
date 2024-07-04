#!/bin/bash -e

NGINX_VERSION=1.26.1

echo "Installing nginx ${NGINX_VERSION}"

groupadd --system --gid 950 docker-machines
useradd --system --create-home --gid docker-machines --uid 950 nginx

PKG_RELEASE=2~${DISTRIB_CODENAME}

DEBIAN_FRONTEND=noninteractive apt-get -y -q update
DEBIAN_FRONTEND=noninteractive apt-get -y -q install curl
curl -# -L https://nginx.org/keys/nginx_signing.key > /etc/apt/trusted.gpg.d/nginx.asc
echo "deb https://nginx.org/packages/${DISTRIB_ID}/ ${DISTRIB_CODENAME} nginx" >> /etc/apt/sources.list.d/nginx.list
DEBIAN_FRONTEND=noninteractive apt-get -y -q update
DEBIAN_FRONTEND=noninteractive apt-get -y -q install --no-install-recommends --no-install-suggests nginx=${NGINX_VERSION}-${PKG_RELEASE} gettext-base
rm -rf /var/lib/apt/lists/* /etc/apt/sources.list.d/nginx.list

cat <<'EOF' > /etc/nginx/nginx.conf

#load_module modules/opfa_http_remove_server_header_module.so;

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

cat <<'EOF' > /etc/nginx/dhparam.pem
-----BEGIN DH PARAMETERS-----
MIIBCAKCAQEA//////////+t+FRYortKmq/cViAnPTzx2LnFg84tNpWp4TZBFGQz
+8yTnc4kmz75fS/jY2MMddj2gbICrsRhetPfHtXV/WVhJDP1H18GbtCFY2VVPe0a
87VXE15/V8k1mE8McODmi3fipona8+/och3xWKE2rec1MKzKT0g6eXq8CrGCsyT7
YdEIqUuyyOP7uWrat2DX9GgdT0Kj3jlN9K5W7edjcrsZCwenyO4KbXCeAvzhzffi
7MA0BM0oNC9hkXL+nOmFg/+OTxIy7vKBg8P+OxtMb61zO7X8vC7CIAXFjvGDfRaD
ssbzSibBsu/6iGtCOGEoXJf//////////wIBAg==
-----END DH PARAMETERS-----
EOF

cat <<'EOF' > /etc/nginx/error_pages.conf
error_page 301 302 303 307 308 400 401 402 403 404 405 406 408 409 410 411 412 413 414 415 416 421 429 494 495 496 497 500 501 502 503 504 505 507 /internal_custom_error;

location /internal_custom_error {
    internal;
    etag off;
    alias empty_body;
}
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

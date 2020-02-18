#!/bin/bash -e

NGINX_VERSION=1.17.8
PKG_RELEASE=1~bionic

echo "Installing nginx ${NGINX_VERSION}"

addgroup --system --gid 20000 docker-machines
adduser --system --disabled-login --ingroup docker-machines --no-create-home --uid 20004 nginx

DEBIAN_FRONTEND=noninteractive apt-get -y -q update
DEBIAN_FRONTEND=noninteractive apt-get -y -q install gnupg1 ca-certificates
DEBIAN_FRONTEND=noninteractive apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62
DEBIAN_FRONTEND=noninteractive apt-get -y -q remove gnupg1 ca-certificates

echo "deb https://nginx.org/packages/mainline/ubuntu/ bionic nginx" >> /etc/apt/sources.list.d/nginx.list
DEBIAN_FRONTEND=noninteractive apt-get -y -q update
DEBIAN_FRONTEND=noninteractive apt-get -y -q install --no-install-recommends --no-install-suggests nginx=${NGINX_VERSION}-${PKG_RELEASE} gettext-base
DEBIAN_FRONTEND=noninteractive apt-get remove -y -q --purge --auto-remove ca-certificates
rm -rf /var/lib/apt/lists/* /etc/apt/sources.list.d/nginx.list


cat <<'EOF' > /etc/nginx/nginx.conf
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

    include /etc/nginx/conf.d/*.conf;
}
EOF

# forward request and error logs to docker log collector
ln -sf /dev/stdout /var/log/nginx/access.log
ln -sf /dev/stderr /var/log/nginx/error.log

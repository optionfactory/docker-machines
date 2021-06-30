#!/bin/bash -e

NGINX_VERSION=1.20.1

echo "Installing nginx ${NGINX_VERSION}"

groupadd --system --gid 20000 docker-machines
useradd --system --create-home --gid docker-machines --uid 20004 nginx

PKG_RELEASE=1~${DISTRIB_CODENAME}

case "${DISTRIB_LABEL}" in
    debian*|ubuntu*)
        DEBIAN_FRONTEND=noninteractive apt-get -y -q update
        DEBIAN_FRONTEND=noninteractive apt-get -y -q install gnupg1 ca-certificates curl
        DEBIAN_FRONTEND=noninteractive curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add -
        DEBIAN_FRONTEND=noninteractive apt-get -y -q remove gnupg1 ca-certificates curl
        echo "deb https://nginx.org/packages/${DISTRIB_ID}/ ${DISTRIB_CODENAME} nginx" >> /etc/apt/sources.list.d/nginx.list
        DEBIAN_FRONTEND=noninteractive apt-get -y -q update
        DEBIAN_FRONTEND=noninteractive apt-get -y -q install --no-install-recommends --no-install-suggests nginx=${NGINX_VERSION}-${PKG_RELEASE} gettext-base
        DEBIAN_FRONTEND=noninteractive apt-get remove -y -q --purge --auto-remove ca-certificates
        rm -rf /var/lib/apt/lists/* /etc/apt/sources.list.d/nginx.list
    ;;
    centos8|rocky8)
        cat << EOF > /etc/yum.repos.d/nginx.repo
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/8/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
EOF
        yum install -q -y nginx
        echo cleaning up
        yum clean all
        rm -rf /var/cache/yum
    ;;
    *)
    echo "distribution ${DISTRIB_LABEL} not supported"
    exit 1
    ;;
esac

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

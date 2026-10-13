#!/bin/bash -e

echo "Installing cinny"

rm -rf /usr/share/cinny
cp -r /build/dist /usr/share/cinny
rm -f /usr/share/cinny/netlify.toml /usr/share/cinny/sw.js.map

# internal web server behind an edge proxy: plain http on 8080, no certificates, no access log (the edge has it)
cat <<'EOS' > /etc/nginx/nginx.conf

load_module modules/opfa_http_remove_server_header_module.so;

user  nginx;
worker_processes  auto;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;

events {
    worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    access_log    off;
    sendfile      on;
    server_tokens off;
    keepalive_timeout  65;

    server {
        listen 8080 default_server;
        root /usr/share/cinny;

        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-Content-Type-Options "nosniff" always;

        location / {
            try_files $uri $uri/ /index.html;
        }
    }
}
EOS

cat <<'EOS' > /cinny
#!/bin/bash -e
exec nginx -g "daemon off;"
EOS

chmod 750 /cinny

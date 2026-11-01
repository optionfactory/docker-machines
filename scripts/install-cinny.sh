#!/bin/bash -e

echo "Installing cinny"

rm -rf /usr/share/cinny
cp -r /build/dist /usr/share/cinny
rm -f /usr/share/cinny/netlify.toml /usr/share/cinny/sw.js.map

# OptionFactory icons in place of Cinny's (scripts/branding/matrix, made by tools/favicons in internal-services)
cinny=/usr/share/cinny
branding=/build-scripts/branding/matrix
icons=("${cinny}"/assets/favicon-*.ico)
if ((${#icons[@]} != 1)); then
    echo "cinny favicon not found exactly once" >&2
    exit 1
fi
cp "${branding}/favicon.ico" "${icons[0]}"
for icon in "${cinny}"/assets/apple-touch-icon-*.png; do
    size=$(basename "${icon}" | cut -d- -f4)
    cp "${branding}/apple-touch-icon-${size}.png" "${icon}"
done
for icon in "${cinny}"/public/android/android-chrome-*.png; do
    cp "${branding}/$(basename "${icon}")" "${icon}"
done
# the page swaps its favicon among three svg data uris in the bundle (normal, unread, mention): found by their content,
# since the names in the bundle change with every release
scripts=("${cinny}"/assets/index-*.js)
for replacement in 'Adobe%20Illustrator%2018 favicon.svg' '%23989898 favicon-unread.svg' '%2345B83B favicon-highlight.svg'; do
    read -r marker svg <<< "${replacement}"
    if (($(grep -o "\"data:image/svg+xml,[^\"]*${marker}[^\"]*\"" "${scripts[@]}" | wc -l) != 1)); then
        echo "cinny icon ${marker} not found exactly once" >&2
        exit 1
    fi
    sed -i "s#\"data:image/svg+xml,[^\"]*${marker}[^\"]*\"#\"data:image/svg+xml;base64,$(base64 -w0 "${branding}/${svg}")\"#" "${scripts[@]}"
done

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

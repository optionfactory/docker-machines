#!/bin/bash -e
find /etc/nginx/certificates/ -maxdepth 1 -name '*.json' -exec legopfa {} ";"
exec nginx -g "daemon off;"

#!/bin/bash -e

exec /lib/systemd/systemd-journal-remote \
    --listen-https=443 \
    --key=/journal-remote-conf/journal-remote.server.key \
    --cert=/journal-remote-conf/journal-remote.server.crt \
    --trust=/journal-remote-conf/journal-remote.trustedca.crt \
    --output=/journal-remote-logs/ \
    --split-mode=host \
    --compress=false

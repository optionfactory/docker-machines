#!/bin/bash -e

echo "Installing base imnage"

cp /build/install-ps1.sh /etc/bash.bashrc
cp /build/gosu-* /usr/local/bin/gosu

DEBIAN_FRONTEND=noninteractive apt -y -q update
DEBIAN_FRONTEND=noninteractive apt install -y -q ca-certificates
DEBIAN_FRONTEND=noninteractive apt clean -y -q
rm -rf /var/lib/apt/lists/*

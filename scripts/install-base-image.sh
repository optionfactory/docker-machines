#!/bin/bash -e

echo "Installing base image"

cp /build-scripts/install-ps1.sh /etc/bash.bashrc

DEBIAN_FRONTEND=noninteractive apt-get -y -q update
DEBIAN_FRONTEND=noninteractive apt-get install -y -q --no-install-recommends ca-certificates
DEBIAN_FRONTEND=noninteractive apt-get clean -y -q
rm -rf /var/lib/apt/lists/*

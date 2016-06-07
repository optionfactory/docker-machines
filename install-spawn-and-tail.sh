#!/bin/bash -e
curl -# -j -k -L  https://github.com/optionfactory/spawn-and-tail/releases/download/v0.2/spawn-and-tail-linux-amd64 > /tmp/spawn-and-tail
install -T /tmp/spawn-and-tail /usr/bin/sat
rm -rf /tmp/spawn-and-tail


#!/bin/bash -e


if [ -f /usr/bin/apt-get ]; then
    DEBIAN_FRONTEND=noninteractive apt-get -y -q update
    DEBIAN_FRONTEND=noninteractive apt-get -y -q --no-install-recommends install ca-certificates g++ gcc libc6-dev make pkg-config inotify-tools git
    DEBIAN_FRONTEND=noninteractive apt-get -y -q autoclean
    DEBIAN_FRONTEND=noninteractive apt-get -y -q autoremove
    rm -rf /var/lib/apt/lists/*
elif [ -f /usr/bin/zypper ] ; then
    zypper -n -q install ca-certificates g++ gcc libc6-dev make pkg-config inotify-tools git
    zypper -n -q clean --all
elif [ -f /usr/bin/yum ] ; then
    yum install -q -y ca-certificates g++ gcc libc6-dev make pkg-config inotify-tools git
    yum clean all
    rm -rf /var/cache/yum
else
    echo "unknown or missing package manager"
    exit 1
fi



# set up nsswitch.conf for Go's "netgo" implementation
# - https://github.com/golang/go/blob/go1.9.1/src/net/conf.go#L194-L275
# - docker run --rm debian:stretch grep '^hosts:' /etc/nsswitch.conf
[ ! -e /etc/nsswitch.conf ] && echo 'hosts: files dns' > /etc/nsswitch.conf

cp -r /tmp/golang-* /usr/local/go

export PATH="/usr/local/go/bin:$PATH";
go version

mkdir -p "$GOPATH/src" "$GOPATH/bin"
chmod -R 777 "$GOPATH"

#common packages we don't want do download every time
go get -u github.com/jteeuwen/go-bindata/...
go get -u github.com/elazarl/go-bindata-assetfs/...

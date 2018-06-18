FROM golang:1.10
MAINTAINER Roberto Ferranti <roberto@optionfactory.net>

RUN DEBIAN_FRONTEND=noninteractive apt-get update -q -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -q -y inotify-tools
RUN DEBIAN_FRONTEND=noninteractive apt-get -y -q autoclean
RUN DEBIAN_FRONTEND=noninteractive apt-get -y -q autoremove
RUN rm -rf /var/lib/apt/lists/*

#common packages we don't want to download every time
RUN go get -u github.com/jteeuwen/go-bindata/...
RUN go get -u github.com/elazarl/go-bindata-assetfs/...

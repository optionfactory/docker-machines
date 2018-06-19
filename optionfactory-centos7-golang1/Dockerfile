FROM optionfactory/centos7:latest
MAINTAINER Roberto Ferranti <roberto@optionfactory.net>

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

COPY deps /tmp/
RUN /tmp/install-golang.sh
RUN rm -rf /tmp/*

WORKDIR $GOPATH

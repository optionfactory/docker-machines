FROM optionfactory/ubuntu18-golang1:latest
MAINTAINER Roberto Ferranti <roberto@optionfactory.net>

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

COPY deps /tmp/
RUN /tmp/install-atom1.sh
RUN rm -rf /tmp/*

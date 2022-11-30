FROM optionfactory/rocky9:latest
LABEL maintainer="Roberto Ferranti <roberto@optionfactory.net>"

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

COPY deps /tmp/
RUN DISTRIB_LABEL=rocky9 DISTRIB_ID=rocky DISTRIB_RELEASE=9 DISTRIB_CODENAME=9 /tmp/install-golang1.sh
RUN rm -rf /tmp/*

WORKDIR $GOPATH


FROM optionfactory/centos8:latest
MAINTAINER Roberto Ferranti <roberto@optionfactory.net>

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

COPY deps /tmp/
RUN DISTRIB_LABEL=centos8 DISTRIB_ID=centos DISTRIB_RELEASE=8 DISTRIB_CODENAME=8 /tmp/install-golang1.sh
RUN cp /tmp/golang1-project-makefile.tpl /project-makefile.tpl
RUN cp /tmp/init-golang1.sh /goinit
RUN rm -rf /tmp/*

WORKDIR $GOPATH
ENTRYPOINT ["/goinit"]

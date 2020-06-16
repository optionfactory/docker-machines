FROM optionfactory/ubuntu18:latest
MAINTAINER Roberto Ferranti <roberto@optionfactory.net>

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

COPY deps /tmp/
RUN DISTRIB_LABEL=ubuntu18 DISTRIB_ID=ubuntu DISTRIB_RELEASE=18.04 DISTRIB_CODENAME=bionic /tmp/install-golang1.sh
RUN cp /tmp/golang1-project-makefile.tpl /project-makefile.tpl
RUN cp /tmp/init-golang1.sh /goinit
RUN rm -rf /tmp/*

WORKDIR $GOPATH
ENTRYPOINT ["/goinit"]

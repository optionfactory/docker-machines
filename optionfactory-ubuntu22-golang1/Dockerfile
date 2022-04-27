FROM optionfactory/ubuntu22:latest
LABEL maintainer="Roberto Ferranti <roberto@optionfactory.net>"

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

COPY deps /tmp/
RUN DISTRIB_LABEL=ubuntu22 DISTRIB_ID=ubuntu DISTRIB_RELEASE=22.04 DISTRIB_CODENAME=jammy /tmp/install-golang1.sh
RUN cp /tmp/golang1-project-makefile.tpl /project-makefile.tpl
RUN cp /tmp/init-golang1.sh /goinit
RUN rm -rf /tmp/*

WORKDIR $GOPATH
ENTRYPOINT ["/goinit"]

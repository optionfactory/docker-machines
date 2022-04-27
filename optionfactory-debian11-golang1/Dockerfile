FROM optionfactory/debian11:latest
LABEL maintainer="Roberto Ferranti <roberto@optionfactory.net>"

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

COPY deps /tmp/
RUN DISTRIB_LABEL=debian11 DISTRIB_ID=debian DISTRIB_RELEASE=11 DISTRIB_CODENAME=bullseye /tmp/install-golang1.sh
RUN cp /tmp/golang1-project-makefile.tpl /project-makefile.tpl
RUN cp /tmp/init-golang1.sh /goinit
RUN rm -rf /tmp/*

WORKDIR $GOPATH
ENTRYPOINT ["/goinit"]

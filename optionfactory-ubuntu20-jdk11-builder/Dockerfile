FROM optionfactory/ubuntu20-jdk11:latest
MAINTAINER Roberto Ferranti <roberto@optionfactory.net>

COPY deps /tmp/
RUN DISTRIB_LABEL=ubuntu20 DISTRIB_ID=ubuntu DISTRIB_RELEASE=20.04 DISTRIB_CODENAME=focal /tmp/install-builder.sh
RUN cp /tmp/init-builder.sh /builder
RUN rm -rf /tmp/*

WORKDIR $GOPATH
ENTRYPOINT ["/builder"]

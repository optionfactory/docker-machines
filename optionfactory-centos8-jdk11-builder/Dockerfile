FROM optionfactory/centos8-jdk11:latest
MAINTAINER Roberto Ferranti <roberto@optionfactory.net>

COPY deps /tmp/
RUN DISTRIB_LABEL=centos8 DISTRIB_ID=centos DISTRIB_RELEASE=8 DISTRIB_CODENAME=8 /tmp/install-builder.sh
RUN cp /tmp/init-builder.sh /builder
RUN rm -rf /tmp/*

WORKDIR /home/builder
USER builder

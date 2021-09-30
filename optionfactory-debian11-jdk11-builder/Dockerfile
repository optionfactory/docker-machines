FROM optionfactory/debian11-jdk11:latest
MAINTAINER Roberto Ferranti <roberto@optionfactory.net>


COPY deps /tmp/
RUN DISTRIB_LABEL=debian11 DISTRIB_ID=debian DISTRIB_RELEASE=11 DISTRIB_CODENAME=bullseye /tmp/install-builder.sh
RUN rm -rf /tmp/*

WORKDIR /home/builder
USER builder

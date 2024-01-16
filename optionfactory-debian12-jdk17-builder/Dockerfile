FROM optionfactory/debian12-jdk17:latest
LABEL maintainer="Roberto Ferranti <roberto@optionfactory.net>"
LABEL org.opencontainers.image.source https://github.com/optionfactory/docker-machines

COPY deps /tmp/
RUN DISTRIB_LABEL=debian12 DISTRIB_ID=debian DISTRIB_RELEASE=12 DISTRIB_CODENAME=bookworm /tmp/install-builder.sh
RUN rm -rf /tmp/*

WORKDIR /home/builder
USER builder

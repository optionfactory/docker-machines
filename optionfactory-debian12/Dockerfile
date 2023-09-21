FROM debian:bookworm
LABEL maintainer="Roberto Ferranti <roberto@optionfactory.net>"
LABEL org.opencontainers.image.source https://github.com/optionfactory/docker-machines

COPY deps /tmp/
RUN cp /tmp/install-ps1.sh /etc/bash.bashrc
RUN cp /tmp/gosu-*  /usr/local/bin/gosu
RUN rm -rf /tmp/*

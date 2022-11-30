FROM debian:bullseye
LABEL maintainer="Roberto Ferranti <roberto@optionfactory.net>"

COPY deps /tmp/
RUN cp /tmp/install-ps1.sh /etc/bash.bashrc
RUN cp /tmp/gosu-*  /usr/local/bin/gosu
RUN rm -rf /tmp/*

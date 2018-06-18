FROM opensuse/leap:15.0
MAINTAINER Roberto Ferranti <roberto@optionfactory.net>

COPY deps /tmp/
RUN cp /tmp/install-ps1.sh /etc/bash.bashrc.local
RUN /tmp/install-spawn-and-tail.sh
RUN rm -rf /tmp/*

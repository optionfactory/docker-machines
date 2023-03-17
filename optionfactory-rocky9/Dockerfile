FROM rockylinux/rockylinux:9
LABEL maintainer="Roberto Ferranti <roberto@optionfactory.net>"
LABEL org.opencontainers.image.source https://github.com/optionfactory/docker-machines

COPY deps /tmp/
RUN cp /tmp/install-ps1.sh /etc/profile.d/ps1.sh
RUN cp /tmp/gosu-*  /usr/local/bin/gosu
RUN rm -rf /tmp/*
RUN sed -i 's/^SYS_UID_MAX.*$/SYS_UID_MAX 29999/g' /etc/login.defs
RUN sed -i 's/^UID_MIN.*$/UID_MIN 30000/g' /etc/login.defs
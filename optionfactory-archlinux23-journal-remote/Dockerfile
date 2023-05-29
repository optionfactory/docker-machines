FROM optionfactory/arch23:latest
LABEL maintainer="Roberto Ferranti <roberto@optionfactory.net>"
LABEL org.opencontainers.image.source https://github.com/optionfactory/docker-machines

COPY deps /tmp/
RUN DISTRIB_LABEL=archlinux23 DISTRIB_ID=archlinux DISTRIB_RELEASE=23 DISTRIB_CODENAME=23 /tmp/install-journal-remote.sh
RUN cp /tmp/init-journal-remote.sh /journal-remote
RUN rm -rf /tmp/*

ENTRYPOINT ["/journal-remote"]

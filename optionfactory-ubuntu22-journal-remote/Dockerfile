FROM optionfactory/ubuntu22:latest
LABEL maintainer="Roberto Ferranti <roberto@optionfactory.net>"
LABEL org.opencontainers.image.source https://github.com/optionfactory/docker-machines

COPY deps /tmp/
RUN DISTRIB_LABEL=ubuntu22 DISTRIB_ID=ubuntu DISTRIB_RELEASE=22.04 DISTRIB_CODENAME=jammy /tmp/install-journal-remote.sh
RUN cp /tmp/init-journal-remote.sh /journal-remote
RUN rm -rf /tmp/*

ENTRYPOINT ["/journal-remote"]

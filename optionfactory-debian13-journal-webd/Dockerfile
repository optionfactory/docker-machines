FROM optionfactory/debian13:latest
LABEL maintainer="Roberto Ferranti <roberto@optionfactory.net>"
LABEL org.opencontainers.image.source https://github.com/optionfactory/docker-machines

COPY deps /tmp/
RUN DISTRIB_LABEL=debian13 DISTRIB_ID=debian DISTRIB_RELEASE=13 DISTRIB_CODENAME=trixie /tmp/install-journal-webd.sh
RUN rm -rf /tmp/*

ENTRYPOINT ["/journal-webd", "/configuration.json"]

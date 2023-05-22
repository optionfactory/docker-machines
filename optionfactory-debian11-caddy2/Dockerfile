FROM optionfactory/debian11:latest
LABEL maintainer="Roberto Ferranti <roberto@optionfactory.net>"
LABEL org.opencontainers.image.source https://github.com/optionfactory/docker-machines

COPY deps /tmp/
RUN DISTRIB_LABEL=debian11 DISTRIB_ID=debian DISTRIB_RELEASE=11 DISTRIB_CODENAME=bullseye /tmp/install-caddy2.sh
RUN cp /tmp/init-caddy2.sh /caddy
RUN rm -rf /tmp/*

ENTRYPOINT ["/caddy"]

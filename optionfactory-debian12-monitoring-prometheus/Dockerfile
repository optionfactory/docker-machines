FROM optionfactory/debian12:latest
LABEL maintainer="Roberto Ferranti <roberto@optionfactory.net>"
LABEL org.opencontainers.image.source https://github.com/optionfactory/docker-machines

RUN --mount=type=bind,source=deps,target=build \
    DISTRIB_LABEL=debian12 DISTRIB_ID=debian DISTRIB_RELEASE=12 DISTRIB_CODENAME=bookworm \
    /build/install-monitoring-prometheus.sh


ENTRYPOINT ["/prometheus"]



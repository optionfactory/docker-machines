FROM optionfactory/debian13:latest
LABEL maintainer="Roberto Ferranti <roberto@optionfactory.net>"
LABEL org.opencontainers.image.source=https://github.com/optionfactory/docker-machines

RUN --mount=type=bind,source=deps,target=build \
    DISTRIB_LABEL=debian13 DISTRIB_ID=debian DISTRIB_RELEASE=13 DISTRIB_CODENAME=trixie \
    /build/install-monitoring-prometheus.sh


ENTRYPOINT ["/prometheus"]



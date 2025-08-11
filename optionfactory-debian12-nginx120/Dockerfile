FROM optionfactory/debian12:latest
LABEL maintainer="Roberto Ferranti <roberto@optionfactory.net>"
LABEL org.opencontainers.image.source=https://github.com/optionfactory/docker-machines

ARG NGINX_MAJOR_VERSION

RUN --mount=type=bind,source=deps,target=build \
    DISTRIB_LABEL=debian12 DISTRIB_ID=debian DISTRIB_RELEASE=12 DISTRIB_CODENAME=bookworm \
    NGINX_MAJOR_VERSION=${NGINX_MAJOR_VERSION} \
    /build/install-nginx.sh

ENTRYPOINT ["/nginx"]

FROM optionfactory/debian13:latest
LABEL maintainer="Roberto Ferranti <roberto@optionfactory.net>"
LABEL org.opencontainers.image.source=https://github.com/optionfactory/docker-machines

ARG MARIA_DB_VERSION

RUN --mount=type=bind,source=deps,target=build \
    DISTRIB_LABEL=debian13 DISTRIB_ID=debian DISTRIB_RELEASE=13 DISTRIB_CODENAME=trixie \
    MARIA_DB_VERSION=${MARIA_DB_VERSION} \
    /build/install-mariadb10.sh

VOLUME ["/var/lib/mysql", "/sql-init.d/"]
ENTRYPOINT ["/mariadb"]

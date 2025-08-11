FROM optionfactory/debian13:latest
LABEL maintainer="Roberto Ferranti <roberto@optionfactory.net>"
LABEL org.opencontainers.image.source=https://github.com/optionfactory/docker-machines

RUN --mount=type=bind,source=deps,target=build \
    DISTRIB_LABEL=debian13 DISTRIB_ID=debian DISTRIB_RELEASE=13 DISTRIB_CODENAME=trixie \
    MARIA_DB_VERSION=12.rolling \
    /build/install-mariadb.sh

VOLUME ["/var/lib/mysql", "/sql-init.d/"]
ENTRYPOINT ["/mariadb"]

FROM optionfactory/debian13:latest
LABEL maintainer="Roberto Ferranti <roberto@optionfactory.net>"
LABEL org.opencontainers.image.source=https://github.com/optionfactory/docker-machines

ARG PSQL_MAJOR_VERSION

RUN --mount=type=bind,source=deps,target=build \
    DISTRIB_LABEL=debian13 DISTRIB_ID=debian DISTRIB_RELEASE=13 DISTRIB_CODENAME=trixie \
    PSQL_MAJOR_VERSION=${PSQL_MAJOR_VERSION} \
    /build/install-postgres.sh

VOLUME ["/var/lib/postgresql/data/", "/sql-init.d/"]
ENTRYPOINT ["/postgres"]

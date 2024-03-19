FROM optionfactory/rocky9-jdk17:latest
LABEL maintainer="Roberto Ferranti <roberto@optionfactory.net>"
LABEL org.opencontainers.image.source https://github.com/optionfactory/docker-machines

RUN --mount=type=bind,source=deps,target=build \
    DISTRIB_LABEL=rocky9 DISTRIB_ID=rocky DISTRIB_RELEASE=9 DISTRIB_CODENAME=9 TOMCAT_MAJOR_VERSION=9 \
    /build/install-tomcat.sh

ENTRYPOINT ["/tomcat"]

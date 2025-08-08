FROM optionfactory/debian13-jdk21:latest
LABEL maintainer="Roberto Ferranti <roberto@optionfactory.net>"
LABEL org.opencontainers.image.source=https://github.com/optionfactory/docker-machines

ARG TOMCAT_MAJOR_VERSION

RUN --mount=type=bind,source=deps,target=build \
    DISTRIB_LABEL=debian13 DISTRIB_ID=debian DISTRIB_RELEASE=13 DISTRIB_CODENAME=trixie \
    TOMCAT_MAJOR_VERSION=${TOMCAT_MAJOR_VERSION} \
    /build/install-tomcat.sh

ENTRYPOINT ["/tomcat"]

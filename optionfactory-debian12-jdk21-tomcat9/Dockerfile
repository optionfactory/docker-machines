FROM optionfactory/debian12-jdk21:latest
LABEL maintainer="Roberto Ferranti <roberto@optionfactory.net>"
LABEL org.opencontainers.image.source https://github.com/optionfactory/docker-machines

RUN --mount=type=bind,source=deps,target=build \
    DISTRIB_LABEL=debian12 DISTRIB_ID=debian DISTRIB_RELEASE=12 DISTRIB_CODENAME=bookworm TOMCAT_MAJOR_VERSION=9 JDK_MAJOR_VERSION=21 \
    /build/install-tomcat.sh

ENTRYPOINT ["/tomcat"]

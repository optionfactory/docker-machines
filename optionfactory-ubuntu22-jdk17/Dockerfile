FROM optionfactory/ubuntu22:latest
MAINTAINER Roberto Ferranti <roberto@optionfactory.net>

COPY deps /tmp/
RUN DISTRIB_LABEL=ubuntu22 DISTRIB_ID=ubuntu DISTRIB_RELEASE=22.04 DISTRIB_CODENAME=jammy /tmp/install-jdk.sh
RUN rm -rf /tmp/*

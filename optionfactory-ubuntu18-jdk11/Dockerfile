FROM optionfactory/ubuntu18:latest
MAINTAINER Roberto Ferranti <roberto@optionfactory.net>

COPY deps /tmp/
RUN DISTRIB_LABEL=ubuntu18 DISTRIB_ID=ubuntu DISTRIB_RELEASE=18.04 DISTRIB_CODENAME=bionic /tmp/install-jdk11.sh
RUN rm -rf /tmp/*

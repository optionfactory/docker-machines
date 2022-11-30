FROM optionfactory/rocky9-jdk11:latest
LABEL maintainer="Roberto Ferranti <roberto@optionfactory.net>"

COPY deps /tmp/
RUN DISTRIB_LABEL=rocky9 DISTRIB_ID=rocky DISTRIB_RELEASE=9 DISTRIB_CODENAME=9 /tmp/install-builder.sh
RUN rm -rf /tmp/*

WORKDIR /home/builder
USER builder

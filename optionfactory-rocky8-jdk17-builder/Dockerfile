FROM optionfactory/rocky8-jdk17:latest
LABEL maintainer="Roberto Ferranti <roberto@optionfactory.net>"

COPY deps /tmp/
RUN DISTRIB_LABEL=rocky8 DISTRIB_ID=rocky DISTRIB_RELEASE=8 DISTRIB_CODENAME=8 /tmp/install-builder.sh
RUN rm -rf /tmp/*

WORKDIR /home/builder
USER builder

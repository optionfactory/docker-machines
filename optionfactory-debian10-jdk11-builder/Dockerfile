FROM optionfactory/debian10-jdk11:latest
MAINTAINER Roberto Ferranti <roberto@optionfactory.net>


COPY deps /tmp/
RUN DISTRIB_LABEL=debian10 DISTRIB_ID=debian DISTRIB_RELEASE=10 DISTRIB_CODENAME=buster /tmp/install-builder.sh
RUN cp /tmp/init-builder.sh /builder
RUN rm -rf /tmp/*

WORKDIR /home/builder
USER builder

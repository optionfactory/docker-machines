FROM optionfactory/debian10:latest
MAINTAINER Roberto Ferranti <roberto@optionfactory.net>

COPY deps /tmp/
RUN /tmp/install-jdk11.sh
RUN rm -rf /tmp/*

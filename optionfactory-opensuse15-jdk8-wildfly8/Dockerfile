FROM optionfactory/opensuse15-jdk8:latest
MAINTAINER Roberto Ferranti <roberto@optionfactory.net>

COPY deps /tmp/

RUN /tmp/install-wildfly8.sh
RUN cp /tmp/init-wildfly8.sh /wildfly
RUN rm -rf /tmp/*

USER wildfly

EXPOSE 8443 9990

ENTRYPOINT ["/wildfly"]

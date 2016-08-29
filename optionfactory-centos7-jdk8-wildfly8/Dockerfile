FROM optionfactory/centos7-jdk8:latest
MAINTAINER Roberto Ferranti

COPY deps /tmp/

RUN /tmp/install-wildfly.sh
RUN cp /tmp/init-wildfly.sh /wildfly
RUN rm -rf /tmp/*

USER wildfly

EXPOSE 8443 9990

ENTRYPOINT ["/wildfly"]
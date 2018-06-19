FROM optionfactory/centos7-jdk8:latest
MAINTAINER Roberto Ferranti <roberto@optionfactory.net>

COPY deps /tmp/
RUN /tmp/install-nexus3.sh
RUN cp /tmp/init-nexus3.sh /nexus
RUN rm -rf /tmp/*

VOLUME /opt/nexus/data
EXPOSE 8081
WORKDIR /opt/nexus
USER nexus

ENTRYPOINT ["/nexus"]

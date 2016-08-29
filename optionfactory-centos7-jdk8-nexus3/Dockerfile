FROM optionfactory/centos7-jdk8:latest
MAINTAINER Roberto Ferranti

COPY deps /tmp/
RUN /tmp/install-nexus.sh
RUN cp /tmp/init-nexus.sh /nexus
RUN rm -rf /tmp/*

VOLUME /opt/nexus/data
EXPOSE 8081
WORKDIR /opt/nexus
USER nexus

ENTRYPOINT ["/nexus"]
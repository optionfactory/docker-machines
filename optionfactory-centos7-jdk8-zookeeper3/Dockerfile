FROM optionfactory/centos7-jdk8:latest
MAINTAINER Roberto Ferranti <roberto@optionfactory.net>

COPY deps /tmp/

RUN /tmp/install-zookeeper.sh
RUN cp /tmp/init-zookeeper.sh /zookeeper
RUN rm -rf /tmp/*

EXPOSE 2181 2888 3888

WORKDIR /opt/zookeeper/
VOLUME ["/var/lib/zookeeper"]
ENTRYPOINT ["/zookeeper"]

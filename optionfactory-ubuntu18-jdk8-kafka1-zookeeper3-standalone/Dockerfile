FROM optionfactory/ubuntu18-jdk8:latest
MAINTAINER Roberto Ferranti <roberto@optionfactory.net>

COPY deps /tmp/

RUN /tmp/install-kafka1.sh
RUN /tmp/install-zookeeper3.sh
RUN /tmp/install-kafka1-zookeeper3-standalone.sh
RUN cp /tmp/init-kafka1-zookeeper3-standalone.sh /kafka-zoo
RUN rm -rf /tmp/*

EXPOSE 9092 2181 2888 3888

ENTRYPOINT ["/kafka-zoo"]

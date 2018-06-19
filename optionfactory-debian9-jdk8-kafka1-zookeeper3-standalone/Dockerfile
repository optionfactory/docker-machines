FROM optionfactory/debian9-jdk8:latest
MAINTAINER Roberto Ferranti <roberto@optionfactory.net>

COPY deps /tmp/

RUN /tmp/install-kafka.sh
RUN /tmp/install-zookeeper.sh
RUN /tmp/install-kafka-zookeeper-standalone.sh
RUN cp /tmp/init-kafka-zookeeper-standalone.sh /kafka-zoo
RUN rm -rf /tmp/*

EXPOSE 9092 2181 2888 3888

ENTRYPOINT ["/kafka-zoo"]

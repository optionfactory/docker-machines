FROM optionfactory/ubuntu18-jdk8:latest
MAINTAINER Roberto Ferranti <roberto@optionfactory.net>

COPY deps /tmp/

RUN /tmp/install-kafka.sh
RUN cp /tmp/init-kafka.sh /kafka
RUN rm -rf /tmp/*

EXPOSE 9092

ENTRYPOINT ["/kafka"]

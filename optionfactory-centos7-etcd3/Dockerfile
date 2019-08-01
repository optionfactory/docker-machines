FROM optionfactory/centos7:latest
MAINTAINER Roberto Ferranti <roberto@optionfactory.net>

COPY deps /tmp/

RUN /tmp/install-etcd3.sh
RUN cp /tmp/init-etcd3.sh /etcd

RUN rm -rf /tmp/*

VOLUME /opt/etcd/data
VOLUME /opt/etcd/conf

ENTRYPOINT ["/etcd"]

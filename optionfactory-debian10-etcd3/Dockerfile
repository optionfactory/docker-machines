FROM optionfactory/debian10:latest
MAINTAINER Roberto Ferranti <roberto@optionfactory.net>

COPY deps /tmp/

RUN DISTRIB_LABEL=debian10 DISTRIB_ID=debian DISTRIB_RELEASE=10 DISTRIB_CODENAME=buster /tmp/install-etcd3.sh
RUN cp /tmp/init-etcd3.sh /etcd

RUN rm -rf /tmp/*

VOLUME /opt/etcd/data
VOLUME /opt/etcd/conf

ENTRYPOINT ["/etcd"]

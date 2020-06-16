FROM optionfactory/ubuntu20:latest
MAINTAINER Roberto Ferranti <roberto@optionfactory.net>

COPY deps /tmp/

RUN DISTRIB_LABEL=ubuntu20 DISTRIB_ID=ubuntu DISTRIB_RELEASE=20.04 DISTRIB_CODENAME=focal /tmp/install-etcd3.sh
RUN cp /tmp/init-etcd3.sh /etcd

RUN rm -rf /tmp/*

VOLUME /opt/etcd/data
VOLUME /opt/etcd/conf

ENTRYPOINT ["/etcd"]

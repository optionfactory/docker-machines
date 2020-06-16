FROM optionfactory/centos8:latest
MAINTAINER Roberto Ferranti <roberto@optionfactory.net>

COPY deps /tmp/

RUN DISTRIB_LABEL=centos8 DISTRIB_ID=centos DISTRIB_RELEASE=8 DISTRIB_CODENAME=8 /tmp/install-etcd3.sh
RUN cp /tmp/init-etcd3.sh /etcd

RUN rm -rf /tmp/*

VOLUME /opt/etcd/data
VOLUME /opt/etcd/conf

ENTRYPOINT ["/etcd"]

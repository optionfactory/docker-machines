FROM optionfactory/ubuntu22:latest
LABEL maintainer="Roberto Ferranti <roberto@optionfactory.net>"

COPY deps /tmp/

RUN DISTRIB_LABEL=ubuntu22 DISTRIB_ID=ubuntu DISTRIB_RELEASE=22.04 DISTRIB_CODENAME=jammy /tmp/install-etcd3.sh
RUN cp /tmp/init-etcd3.sh /etcd

RUN rm -rf /tmp/*

VOLUME /opt/etcd/data
VOLUME /opt/etcd/conf

ENTRYPOINT ["/etcd"]

FROM ubuntu:16.04
MAINTAINER Roberto Ferranti


COPY deps /tmp/
RUN /tmp/install-spawn-and-tail.sh
RUN /tmp/install-db2.sh /tmp/*_expc
RUN cp /tmp/init-db2.sh /db2
RUN rm -rf /tmp/*

USER db2inst1
WORKDIR /home/db2inst1/
EXPOSE 50000
ENTRYPOINT ["/db2"]

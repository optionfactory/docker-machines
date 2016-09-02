FROM ubuntu:16.04
MAINTAINER Roberto Ferranti

COPY deps /tmp/
RUN cp /tmp/gosu-* /usr/local/bin/gosu
RUN cp /tmp/install-ps1.sh /etc/bash.bashrc
RUN /tmp/install-spawn-and-tail.sh
RUN /tmp/install-db2.sh /tmp/*_expc 
RUN cp /tmp/init-db2.sh /db2
RUN rm -rf /tmp/*

WORKDIR /home/db2inst1/
EXPOSE 50000
VOLUME ["/home/db2inst1/"]
ENTRYPOINT ["/db2"]
FROM debian:jessie
MAINTAINER Roberto Ferranti

COPY deps /tmp/
RUN cp /tmp/gosu-*  /usr/local/bin/gosu
RUN cp /tmp/install-ps1.sh /etc/bash.bashrc
RUN /tmp/install-postgres.sh
RUN cp /tmp/init-postgres.sh /postgres

RUN rm -rf /tmp/*

EXPOSE 5432
VOLUME ["/var/lib/postgresql/data/", "/sql-init.d/"]
ENTRYPOINT ["/postgres"]
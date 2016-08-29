FROM debian:jessie
MAINTAINER Roberto Ferranti

COPY deps /tmp/

RUN cp /tmp/install-ps1.sh /etc/bash.bashrc
RUN /tmp/install-spawn-and-tail.sh
RUN /tmp/install-mariadb.sh
RUN cp /tmp/init-mariadb.sh /mariadb

RUN rm -rf /tmp/*

USER mysql
EXPOSE 3306

VOLUME ["/var/lib/mysql", "/sql-init.d/"]
ENTRYPOINT ["/mariadb"]
FROM optionfactory/opensuse15:latest
MAINTAINER Roberto Ferranti <roberto@optionfactory.net>

COPY deps /tmp/

RUN /tmp/install-mariadb.sh
RUN cp /tmp/init-mariadb.sh /mariadb

RUN rm -rf /tmp/*

USER mysql
EXPOSE 3306

VOLUME ["/var/lib/mysql", "/sql-init.d/"]
ENTRYPOINT ["/mariadb"]

FROM optionfactory/debian10:latest
MAINTAINER Roberto Ferranti <roberto@optionfactory.net>

COPY deps /tmp/

RUN /tmp/install-mariadb10.sh
RUN cp /tmp/init-mariadb10.sh /mariadb

RUN rm -rf /tmp/*

EXPOSE 3306

VOLUME ["/var/lib/mysql", "/sql-init.d/"]
ENTRYPOINT ["/mariadb"]

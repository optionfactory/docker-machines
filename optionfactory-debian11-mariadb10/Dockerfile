FROM optionfactory/debian11:latest
MAINTAINER Roberto Ferranti <roberto@optionfactory.net>

COPY deps /tmp/

RUN DISTRIB_LABEL=debian11 DISTRIB_ID=debian DISTRIB_RELEASE=11 DISTRIB_CODENAME=bullseye /tmp/install-mariadb10.sh
RUN cp /tmp/init-mariadb10.sh /mariadb

RUN rm -rf /tmp/*

EXPOSE 3306

VOLUME ["/var/lib/mysql", "/sql-init.d/"]
ENTRYPOINT ["/mariadb"]

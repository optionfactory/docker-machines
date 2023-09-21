FROM optionfactory/debian12:latest
LABEL maintainer="Roberto Ferranti <roberto@optionfactory.net>"
LABEL org.opencontainers.image.source https://github.com/optionfactory/docker-machines

COPY deps /tmp/

RUN DISTRIB_LABEL=debian12 DISTRIB_ID=debian DISTRIB_RELEASE=12 DISTRIB_CODENAME=bookworm /tmp/install-mariadb10.sh
RUN cp /tmp/init-mariadb10.sh /mariadb

RUN rm -rf /tmp/*

EXPOSE 3306

VOLUME ["/var/lib/mysql", "/sql-init.d/"]
ENTRYPOINT ["/mariadb"]

FROM optionfactory/ubuntu18:latest
MAINTAINER Roberto Ferranti <roberto@optionfactory.net>

COPY deps /tmp/
RUN DISTRIB_LABEL=ubuntu18 DISTRIB_ID=ubuntu DISTRIB_RELEASE=18.04 DISTRIB_CODENAME=bionic /tmp/install-postgres12.sh
RUN cp /tmp/init-postgres12.sh /postgres

RUN rm -rf /tmp/*

EXPOSE 5432
VOLUME ["/var/lib/postgresql/data/", "/sql-init.d/"]
ENTRYPOINT ["/postgres"]

FROM optionfactory/rocky9:latest
LABEL maintainer="Roberto Ferranti <roberto@optionfactory.net>"

COPY deps /tmp/
RUN DISTRIB_LABEL=rocky9 DISTRIB_ID=rocky DISTRIB_RELEASE=9 DISTRIB_CODENAME=9 PSQL_MAJOR_VERSION=14 /tmp/install-postgres.sh
RUN cp /tmp/init-postgres.sh /postgres

RUN rm -rf /tmp/*

EXPOSE 5432
VOLUME ["/var/lib/postgresql/data/", "/sql-init.d/"]
ENTRYPOINT ["/postgres"]

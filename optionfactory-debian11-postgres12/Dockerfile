FROM optionfactory/debian11:latest
LABEL maintainer="Roberto Ferranti <roberto@optionfactory.net>"

COPY deps /tmp/
RUN DISTRIB_LABEL=debian11 DISTRIB_ID=debian DISTRIB_RELEASE=11 DISTRIB_CODENAME=bullseye PSQL_MAJOR_VERSION=12 /tmp/install-postgres.sh
RUN cp /tmp/init-postgres.sh /postgres

RUN rm -rf /tmp/*

EXPOSE 5432
VOLUME ["/var/lib/postgresql/data/", "/sql-init.d/"]
ENTRYPOINT ["/postgres"]

FROM optionfactory/ubuntu22:latest
LABEL maintainer="Roberto Ferranti <roberto@optionfactory.net>"

COPY deps /tmp/
RUN DISTRIB_LABEL=ubuntu22 DISTRIB_ID=ubuntu DISTRIB_RELEASE=22.04 DISTRIB_CODENAME=jammy PSQL_MAJOR_VERSION=15 /tmp/install-postgres.sh
RUN cp /tmp/init-postgres.sh /postgres

RUN rm -rf /tmp/*

EXPOSE 5432
VOLUME ["/var/lib/postgresql/data/", "/sql-init.d/"]
ENTRYPOINT ["/postgres"]

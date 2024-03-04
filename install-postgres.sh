#!/bin/bash -e

groupadd --system --gid 950 docker-machines
useradd --system --create-home --gid docker-machines --uid 950 postgres


case "${DISTRIB_LABEL}" in
    debian*|ubuntu*)
        DEBIAN_FRONTEND=noninteractive apt-get -y -q update
        DEBIAN_FRONTEND=noninteractive apt-get install -y -q curl
        curl -# -L https://www.postgresql.org/media/keys/ACCC4CF8.asc > /etc/apt/trusted.gpg.d/postgres.asc
        echo "deb http://apt.postgresql.org/pub/repos/apt/ ${DISTRIB_CODENAME}-pgdg main" > /etc/apt/sources.list.d/pgdg.list
        DEBIAN_FRONTEND=noninteractive apt-get -y -q update
        DEBIAN_FRONTEND=noninteractive apt-get install -y -q postgresql-common 
        sed -ri 's/^# *(create_main_cluster) .*$/\1 = false/' /etc/postgresql-common/createcluster.conf
        DEBIAN_FRONTEND=noninteractive apt-get install -y -q postgresql-${PSQL_MAJOR_VERSION} postgresql-contrib-${PSQL_MAJOR_VERSION} postgresql-${PSQL_MAJOR_VERSION}-postgis-3 postgresql-${PSQL_MAJOR_VERSION}-pgvector patroni
    ;;
    rocky9)
        #we need locales
        yum install -q -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm
        yum install -q -y glibc-locale-source
        yum install -q -y postgresql${PSQL_MAJOR_VERSION} postgresql${PSQL_MAJOR_VERSION}-server postgresql${PSQL_MAJOR_VERSION}-contrib pgvector_${PSQL_MAJOR_VERSION}
        yum clean all
        rm -rf /var/lib/pgsql
        rm -rf /var/cache/yum
        mkdir -p /usr/lib/postgresql
        ln -s /usr/pgsql-${PSQL_MAJOR_VERSION}/ /usr/lib/postgresql/${PSQL_MAJOR_VERSION}
    ;;
    *)
    echo "distribution ${DISTRIB_LABEL} not supported"
    exit 1
    ;;
esac

mkdir -p /var/run/postgresql
chown -R postgres:docker-machines /var/run/postgresql
localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

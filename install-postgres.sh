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

localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

mkdir -p /var/lib/postgresql/{data,conf} /var/run/postgresql
chmod 750 /var/lib/postgresql/{data,conf} /var/run/postgresql
chown -R postgres:docker-machines /var/lib/postgresql/{data,conf} /var/run/postgresql

cat << EOF > /var/lib/postgresql/conf/postgresql.conf
data_directory =  '/var/lib/postgresql/data'
hba_file = '/var/lib/postgresql/conf/pg_hba.conf'	
ident_file = '/var/lib/postgresql/conf/pg_ident.conf'
listen_addresses = '0.0.0.0'
max_connections = 100
shared_buffers = 256MB
dynamic_shared_memory_type = posix
max_wal_size = 1GB
min_wal_size = 80MB
log_destination = 'stderr'
logging_collector = off
log_file_mode = 0640
log_min_duration_statement = 10000
log_line_prefix = '[postgres][a:%a][u:%u][s:%c][x:%x] '
log_timezone = 'Etc/UTC'
datestyle = 'iso, mdy'
timezone = 'Etc/UTC'
lc_messages = C
lc_monetary = C
lc_numeric = C
lc_time = C
default_text_search_config = 'pg_catalog.english'
shared_preload_libraries = 'pg_stat_statements'
password_encryption = 'scram-sha-256'
EOF


cat << EOF > /var/lib/postgresql/conf/pg_ident.conf
# MAPNAME       SYSTEM-USERNAME         PG-USERNAME

EOF


cat << EOF > /var/lib/postgresql/conf/pg_hba.conf
# TYPE  DATABASE        USER            ADDRESS                 METHOD
local   all             all                                     trust
host    all             all             127.0.0.1/32            trust
host    all             all             ::1/128                 trust
local   replication     all                                     trust
host    replication     all             127.0.0.1/32            trust
host    replication     all             ::1/128                 trust
host    all             all             0.0.0.0/0               scram-sha-256

EOF

chown -R postgres:docker-machines /var/lib/postgresql/{data,conf} /var/run/postgresql
cp /build/init-postgres.sh /postgres
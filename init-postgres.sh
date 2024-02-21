#!/bin/bash -e

mkdir -p /var/lib/postgresql/data
chmod 700 /var/lib/postgresql/data
chown -R postgres:docker-machines /var/lib/postgresql/data
if [ -d /run/postgresql ]; then
    chmod g+s /run/postgresql
    chown -R postgres:docker-machines /run/postgresql
fi


if [ -s /patroni.yml ]; then
    echo "Patroni configuration detected. Starting patroni"
    exec gosu postgres:docker-machines patroni /patroni.yml
fi

echo "Patroni configuration '/patroni.yml' missing. Runing as a standalone instance"

if [ ! -s "/var/lib/postgresql/data/PG_VERSION" ]; then
    echo "initializing a new database"
    gosu postgres:docker-machines /usr/lib/postgresql/*/bin/initdb \
        /var/lib/postgresql/data \
        --encoding 'UTF-8' \
        --lc-collate='en_US.UTF-8' \
        --lc-ctype='en_US.UTF-8' \
        --allow-group-access \
        --no-instructions
    sed -ri "s/^#? *(shared_preload_libraries) .*/\1 = 'pg_stat_statements'/" /var/lib/postgresql/data/postgresql.conf
    sed -ri "s/^#? *(logging_collector) .*/\1 = off/" /var/lib/postgresql/data/postgresql.conf
    sed -ri "s/^#? *(log_line_prefix) .*/\1 = '[postgres][a:%a][u:%u][s:%c][x:%x] '/" /var/lib/postgresql/data/postgresql.conf
    sed -ri "s/^#? *(listen_addresses) .*/\1 = '0.0.0.0'/" /var/lib/postgresql/data/postgresql.conf
    sed -ri "s/^#? *(shared_buffers) .*/\1 = 256MB/" /var/lib/postgresql/data/postgresql.conf
    sed -ri "s/^#? *(log_destination) .*/\1 = 'stderr'/" /var/lib/postgresql/data/postgresql.conf
    sed -ri "s/^#? *(log_min_duration_statement) .*/\1 = 10000/" /var/lib/postgresql/data/postgresql.conf
    gosu postgres:docker-machines /usr/lib/postgresql/*/bin/pg_ctl -s \
        -D "/var/lib/postgresql/data" \
        -o "-c listen_addresses='127.0.0.1'" \
        -w start
    psql=( psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "postgres" )
    for f in /sql-init.d/*; do
        case "$f" in
            *.sh)     echo "$0: running $f"; . "$f" ;;
            *.sql)    echo "$0: running $f"; "${psql[@]}" < "$f"; echo ;;
            /sql-init.d/*) echo "no scripts found in /sql-init.d/" ;;
            *)        echo "$0: ignoring $f" ;;
        esac
    done

    gosu postgres:docker-machines /usr/lib/postgresql/*/bin/pg_ctl -s -D "/var/lib/postgresql/data" -m fast -w stop
    echo "host    all    all    0.0.0.0/0    md5" >> /var/lib/postgresql/data/pg_hba.conf
    echo
    echo 'PostgreSQL init process complete; ready for start up.'
    echo
fi

exec gosu postgres:docker-machines /usr/lib/postgresql/*/bin/postgres -D /var/lib/postgresql/data

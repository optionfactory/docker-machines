#!/bin/bash -e

chown -R postgres:docker-machines /var/lib/postgresql/{data,conf}

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
        -D /var/lib/postgresql/data \
        --encoding 'UTF-8' \
        --lc-collate='en_US.UTF-8' \
        --lc-ctype='en_US.UTF-8' \
        --allow-group-access \
        --no-instructions
    rm /var/lib/postgresql/data/{postgresql.conf,pg_hba.conf,pg_ident.conf}
    gosu postgres:docker-machines /usr/lib/postgresql/*/bin/pg_ctl -s \
        -D "/var/lib/postgresql/data" \
        -o "-c listen_addresses='127.0.0.1'" \
        -o "-c config_file=/var/lib/postgresql/conf/postgresql.conf" \
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
    gosu postgres:docker-machines /usr/lib/postgresql/*/bin/pg_ctl -s \
        -D "/var/lib/postgresql/data" \
        -o "-c config_file=/var/lib/postgresql/conf/postgresql.conf" \
        -m fast \
        -w stop
    echo
    echo 'PostgreSQL init process complete; ready for start up.'
    echo
fi

exec gosu postgres:docker-machines /usr/lib/postgresql/*/bin/postgres -c config_file=/var/lib/postgresql/conf/postgresql.conf


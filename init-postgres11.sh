#!/bin/bash -e

if [ $# -eq 0 ]; then
    mkdir -p /var/lib/postgresql/data
    chmod 700 /var/lib/postgresql/data
    chown -R postgres:docker-machines /var/lib/postgresql/data
    if [ -d /run/postgresql ]; then
        chmod g+s /run/postgresql
        chown -R postgres:docker-machines /run/postgresql
    fi

    if [ ! -s "/var/lib/postgresql/data/PG_VERSION" ]; then
        echo "initializing a new database"
        gosu postgres:docker-machines /usr/lib/postgresql/*/bin/initdb /var/lib/postgresql/data -E 'UTF-8' --lc-collate='en_US.UTF-8' --lc-ctype='en_US.UTF-8'
        sed -ri "s/(logging_collector) .*/\1 = off/" /var/lib/postgresql/data/postgresql.conf
        sed -ri "s/(log_line_prefix) .*/\1 = '[postgres][%u@%h:%d] '/" /var/lib/postgresql/data/postgresql.conf
        sed -ri "s/#listen_addresses .*$/listen_addresses='0.0.0.0'/" /var/lib/postgresql/data/postgresql.conf
        echo "host all all 0.0.0.0/0 trust" >> "/var/lib/postgresql/data/pg_hba.conf"
        gosu postgres:docker-machines /usr/lib/postgresql/*/bin/pg_ctl -s -D "/var/lib/postgresql/data" -o "-c listen_addresses='127.0.0.1'" -w start
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

        echo
        echo 'PostgreSQL init process complete; ready for start up.'
        echo
    fi

    exec gosu postgres:docker-machines /usr/lib/postgresql/*/bin/postgres -D /var/lib/postgresql/data
fi

exec "$@"

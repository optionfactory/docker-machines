#!/bin/bash -e

if [ $# -eq 0 ]; then
    chown -R mysql:mysql "/var/lib/mysql"
    if [ ! -d "/var/lib/mysql/mysql" ]; then
        echo "initializing database"
        mysql_install_db --datadir="/var/lib/mysql" >/dev/null 2>&1
        echo "database initialized"
        cat /sql-init.d/*.sql | perl -0777 -pe 's/^\s*#.*\n//gm' | perl -0777 -pe 's/([^\n;])[\r\t\n ]+/\1 /gm' | perl -0777 -pe 's/\n{2,}/\n/g' > /tmp/mariadb-first-time.sql
        exec mysqld --defaults-file=/etc/my.cnf --init-file=/tmp/mariadb-first-time.sql
    fi
    exec mysqld --defaults-file=/etc/my.cnf
fi

exec "$@"


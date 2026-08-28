#!/bin/bash -e

chown -R mysql:mysql /var/lib/mysql
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "initializing database"
	setpriv --reuid=mysql --regid=docker-machines --init-groups -- mysqld --defaults-file=/etc/my.cnf --user=mysql --initialize-insecure
	echo "database initialized"

	mysql_client=( mysql --protocol=socket -uroot )
	setpriv --reuid=mysql --regid=docker-machines --init-groups -- mysqld --defaults-file=/etc/my.cnf --user=mysql --skip-networking &
	jid="$!"
	for i in {30..0}; do
		if echo 'select 1' | "${mysql_client[@]}" &> /dev/null; then
			break
		fi
		echo 'waiting for server to start...'
		sleep 1
	done

	for f in /sql-init.d/*; do
		case "$f" in
			*.sh)     echo "running $f"; . "$f" ;;
			*.sql)    echo "running $f"; "${mysql_client[@]}" < "$f"; echo ;;
			*.sql.gz) echo "running $f"; gunzip -c "$f" | "${mysql_client[@]}"; echo ;;
			/sql-init.d/*) echo "no scripts found in /sql-init.d/" ;;
			*)        echo "ignoring $f" ;;
		esac
		echo
	done
	if ! kill -s TERM "$jid" || ! wait "$jid"; then
		echo >&2 'initialization failed.'
		exit 1
	fi

fi
exec setpriv --reuid=mysql --regid=docker-machines --init-groups -- mysqld --defaults-file=/etc/my.cnf --user=mysql

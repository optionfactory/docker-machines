#!/bin/bash -e
set -o pipefail

# slow/general logs are regular files (the server cannot reliably reopen the container's stderr):
# docker-snitch runs the server as its child, relays those files to stderr and keeps them capped
snitch=( docker-snitch /var/run/mysqld/slow.log /var/run/mysqld/general.log -- )

if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "initializing database"
	setpriv --reuid=mysql --regid=docker-machines --init-groups -- mariadb-install-db --datadir="/var/lib/mysql" --skip-test-db
	echo "database initialized"

	mysql_client=( mariadb --protocol=socket -uroot )
	setpriv --reuid=mysql --regid=docker-machines --init-groups -- "${snitch[@]}" mariadbd --defaults-file=/etc/my.cnf --skip-networking &
	jid="$!"
	for i in {1..30}; do
		kill -0 "$jid" 2>/dev/null || { echo >&2 'server exited during startup.'; wait "$jid" || true; exit 1; }
		mariadb-admin --protocol=socket -uroot ping &>/dev/null && break
		echo 'waiting for server to start...'
		sleep 1
	done
	mariadb-admin --protocol=socket -uroot ping &>/dev/null || { echo >&2 'server did not start within 30 seconds.'; kill -s TERM "$jid"; exit 1; }

	for f in /sql-init.d/*; do
		[ -e "$f" ] || { echo "no scripts found in /sql-init.d/"; break; }
		case "$f" in
			*.sh)     echo "running $f"; . "$f" ;;
			*.sql)    echo "running $f"; "${mysql_client[@]}" < "$f" ;;
			*.sql.gz) echo "running $f"; gunzip -c "$f" | "${mysql_client[@]}" ;;
			*)        echo "ignoring $f" ;;
		esac
	done

	kill -s TERM "$jid" && wait "$jid" || { echo >&2 'initialization failed.'; exit 1; }
	echo "initialization complete"
fi
exec setpriv --reuid=mysql --regid=docker-machines --init-groups -- "${snitch[@]}" mariadbd --defaults-file=/etc/my.cnf

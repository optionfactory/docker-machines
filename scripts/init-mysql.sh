#!/bin/bash -e
set -o pipefail

# slow/general logs are regular files (the server cannot reliably reopen the container's stderr):
# forward them to stderr and cap their size. the server appends (O_APPEND), so truncating is safe;
# tail -F follows truncation. both processes die with the container when the server (PID 1) exits.
query_logs=( /var/run/mysqld/slow.log /var/run/mysqld/general.log )
touch "${query_logs[@]}"
chown mysql:docker-machines "${query_logs[@]}"
tail -q -F -n 0 "${query_logs[@]}" >&2 2>/dev/null &
(
	while sleep "${QUERY_LOG_CHECK_SECONDS:-60}"; do
		for f in "${query_logs[@]}"; do
			if [ "$(stat -c %s "$f")" -gt "${QUERY_LOG_MAX_BYTES:-10485760}" ]; then
				truncate -s 0 "$f"
			fi
		done
	done
) &

if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "initializing database"
	setpriv --reuid=mysql --regid=docker-machines --init-groups -- mysqld --defaults-file=/etc/my.cnf --initialize-insecure
	echo "database initialized"

	mysql_client=( mysql --protocol=socket -uroot )
	setpriv --reuid=mysql --regid=docker-machines --init-groups -- mysqld --defaults-file=/etc/my.cnf --skip-networking &
	jid="$!"
	for i in {1..30}; do
		kill -0 "$jid" 2>/dev/null || { echo >&2 'server exited during startup.'; wait "$jid" || true; exit 1; }
		mysqladmin --protocol=socket -uroot ping &>/dev/null && break
		echo 'waiting for server to start...'
		sleep 1
	done
	mysqladmin --protocol=socket -uroot ping &>/dev/null || { echo >&2 'server did not start within 30 seconds.'; kill -s TERM "$jid"; exit 1; }

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
exec setpriv --reuid=mysql --regid=docker-machines --init-groups -- mysqld --defaults-file=/etc/my.cnf

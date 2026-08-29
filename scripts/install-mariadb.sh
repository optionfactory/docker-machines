#!/bin/bash -e

groupadd --system --gid 950 docker-machines
useradd --system --create-home --gid docker-machines --uid 950 mysql

DEBIAN_FRONTEND=noninteractive apt-get -y -q update 
DEBIAN_FRONTEND=noninteractive apt-get -y -q install curl

curl -LsSo /etc/apt/keyrings/mariadb.gpg https://supplychain.mariadb.com/mariadb-keyring-2019.gpg

cat <<-'EOF' > /etc/apt/preferences.d/mariadb.pref
Package: *
Pin: origin dlm.mariadb.com
Pin-Priority: 1000
EOF
        
cat <<-EOF > /etc/apt/sources.list.d/mariadb.list
deb [arch=amd64 signed-by=/etc/apt/keyrings/mariadb.gpg] https://dlm.mariadb.com/repo/mariadb-server/${MARIA_DB_VERSION}/repo/${DISTRIB_ID} ${DISTRIB_CODENAME} main
EOF

DEBIAN_FRONTEND=noninteractive apt-get -y -q update 
DEBIAN_FRONTEND=noninteractive apt-get -y -q install mariadb-server
DEBIAN_FRONTEND=noninteractive apt-get -y -q autoclean
DEBIAN_FRONTEND=noninteractive apt-get -y -q autoremove
rm -rf /var/lib/apt/lists/*

rm -rf /var/lib/mysql
mkdir -p /var/{lib,run,log}/mysql
chown -R mysql:mysql /var/{lib,log,run}/mysql
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld
mkdir -p /var/run/mysqld
chown -R mysql:mysql /var/run/mysqld

cat <<-'EOF' > /etc/my.cnf
	[mysqld]
	server-id=1
	bind-address=0.0.0.0
	# error log goes to stderr (default). slow/general logs are written here and forwarded to stderr by the entrypoint
	# (the server cannot reliably reopen /dev/stderr itself: permission denied on docker's pipes, ESPIPE on a tty).
	# general log is off; toggle at runtime with SET GLOBAL general_log=1
	log_output=FILE
	slow_query_log=1
	slow_query_log_file=/var/run/mysqld/slow.log
	long_query_time=3
	general_log=0
	general_log_file=/var/run/mysqld/general.log
	innodb_file_per_table=ON
	transaction_isolation=READ-COMMITTED
	character-set-client-handshake = FALSE
	character-set-server = utf8mb4
	collation-server = utf8mb4_unicode_ci
	[client]
	default-character-set = utf8mb4
EOF


chown -R mysql:mysql /etc/my.cnf

mkdir -p /sql-init.d/
chown -R mysql:mysql /sql-init.d/

install -o root -g root -m 755 /build/docker-snitch-* /usr/local/bin/docker-snitch

cp /build-scripts/init-mariadb.sh /mariadb
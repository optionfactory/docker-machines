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
	log_output=TABLE
	slow_query_log=1
	long_query_time=3
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

cat <<-'EOF' > /sql-init.d/000.mariadb-first-time.sql
	DELETE FROM mysql.user ;
	DROP DATABASE IF EXISTS test ;
	CREATE USER 'root'@'%' IDENTIFIED BY '';
	GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION ;
	FLUSH PRIVILEGES ;
EOF

cp /build/init-mariadb.sh /mariadb
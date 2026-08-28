#!/bin/bash -e

groupadd --system --gid 950 docker-machines
useradd --system --create-home --gid docker-machines --uid 950 mysql

DEBIAN_FRONTEND=noninteractive apt-get -y -q update 
DEBIAN_FRONTEND=noninteractive apt-get -y -q install curl gpg

mkdir -p /etc/apt/keyrings
curl -LsS https://repo.mysql.com/RPM-GPG-KEY-mysql-2025 | gpg --dearmor > /etc/apt/keyrings/mysql.gpg

cat <<-'EOF' > /etc/apt/preferences.d/mysql.pref
Package: *
Pin: origin repo.mysql.com
Pin-Priority: 1000
EOF
        
cat <<-EOF > /etc/apt/sources.list.d/mysql.list
deb [arch=amd64 signed-by=/etc/apt/keyrings/mysql.gpg] https://repo.mysql.com/apt/debian ${DISTRIB_CODENAME} mysql-${MYSQL_VERSION}
EOF

DEBIAN_FRONTEND=noninteractive apt-get -y -q update 
DEBIAN_FRONTEND=noninteractive apt-get -y -q install mysql-community-server
DEBIAN_FRONTEND=noninteractive apt-get -y -q autoclean
DEBIAN_FRONTEND=noninteractive apt-get -y -q autoremove
rm -rf /var/lib/apt/lists/*

rm -rf /var/lib/mysql
mkdir -p /var/{lib,log}/mysql
chown -R mysql:mysql /var/{lib,log}/mysql
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld
mkdir -p /var/run/mysqld
chown -R mysql:mysql /var/run/mysqld

cat <<-'EOF' > /etc/my.cnf
	[mysqld]
	server-id=1
	bind-address=0.0.0.0
	port=3306
	socket=/var/run/mysqld/mysqld.sock
	log_output=TABLE
	slow_query_log=1
	long_query_time=3
    innodb_file_per_table=ON
    transaction_isolation=READ-COMMITTED
    character-set-server=utf8mb4
    collation-server=utf8mb4_0900_ai_ci
    [client]
    port=3306
    socket=/var/run/mysqld/mysqld.sock
    default-character-set=utf8mb4
EOF


chown -R mysql:mysql /etc/my.cnf

mkdir -p /sql-init.d/
chown -R mysql:mysql /sql-init.d/

cat <<-'EOF' > /sql-init.d/000.mysql-first-time.sql
	DELETE FROM mysql.user WHERE user NOT IN ('mysql.sys', 'mysql.session', 'mysql.infoschema') OR host NOT IN ('localhost') ;
	DROP DATABASE IF EXISTS test ;
	CREATE USER 'root'@'%' IDENTIFIED BY '' ;
	GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION ;
	FLUSH PRIVILEGES ;
EOF

cp /build-scripts/init-mysql.sh /mysql

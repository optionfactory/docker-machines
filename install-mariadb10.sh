#!/bin/bash -e

groupadd -r mysql
useradd -r -m -g mysql mysql

if [ -f /usr/bin/apt-get ]; then
    DEBIAN_FRONTEND=noninteractive apt-get -y -q update
    DEBIAN_FRONTEND=noninteractive apt-get -y -q install mariadb-server-10.1
    DEBIAN_FRONTEND=noninteractive apt-get -y -q autoclean
    DEBIAN_FRONTEND=noninteractive apt-get -y -q autoremove
    rm -rf /var/lib/apt/lists/*
elif [ -f /usr/bin/zypper ] ; then
    zypper -n -q install mariadb
    zypper -n -q clean --all
elif [ -f /usr/bin/yum ] ; then

	cat <<-'EOF' > /etc/yum.repos.d/mariadb.repo
		[mariadb]
		name = MariaDB
		baseurl = http://yum.mariadb.org/10.1/centos7-amd64
		gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
		gpgcheck=1
	EOF
    yum install -q -y MariaDB-server
    yum clean all
    rm -rf /var/cache/yum
else
    echo "unknown or missing package manager"
    exit 1
fi

rm -rf /var/lib/mysql
mkdir -p /var/{lib,run,log}/mysql
chown -R mysql:mysql /var/{lib,log,run}/mysql


cat <<-'EOF' > /etc/my.cnf
	[mysqld]
	server-id=1
	bind-address=0.0.0.0
	log_output = TABLE
	slow_query_log=1
	long_query_time=3
    innodb_file_per_table=ON    
EOF


chown -R mysql:mysql /etc/my.cnf

mkdir -p /sql-init.d/
chown -R mysql:mysql /sql-init.d/

cat <<-'EOF' > /sql-init.d/000.mariadb-first-time.sql
	DELETE FROM mysql.user ;
	DROP DATABASE IF EXISTS test ;
	CREATE USER 'root'@'%' IDENTIFIED BY '';
	GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION ;
	GRANT ALL ON *.* TO 'root'@'localhost' WITH GRANT OPTION ;
	FLUSH PRIVILEGES ;
EOF

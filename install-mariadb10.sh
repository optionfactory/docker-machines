#!/bin/bash -e

groupadd --system --gid 20000 docker-machines
useradd --system --create-home --gid docker-machines --uid 20003 mysql


if [ -f /usr/bin/apt-get -a -f /etc/lsb-release ]; then
    DEBIAN_FRONTEND=noninteractive apt-get -y -q update
    DEBIAN_FRONTEND=noninteractive apt-get -y -q install software-properties-common
    DEBIAN_FRONTEND=noninteractive apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
    DEBIAN_FRONTEND=noninteractive add-apt-repository 'deb [arch=amd64,arm64,ppc64el] http://mirror.ehv.weppel.nl/mariadb/repo/10.4/ubuntu bionic main'
    DEBIAN_FRONTEND=noninteractive apt-get -y -q update
    DEBIAN_FRONTEND=noninteractive apt-get -y -q install mariadb-server
    DEBIAN_FRONTEND=noninteractive apt-get -y -q autoclean
    DEBIAN_FRONTEND=noninteractive apt-get -y -q autoremove
    rm -rf /var/lib/apt/lists/*
elif [ -f /usr/bin/apt-get ]; then
    DEBIAN_FRONTEND=noninteractive apt-get -y -q update
    DEBIAN_FRONTEND=noninteractive apt-get -y -q install software-properties-common dirmngr
    DEBIAN_FRONTEND=noninteractive apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xF1656F24C74CD1D8
    DEBIAN_FRONTEND=noninteractive add-apt-repository 'deb [arch=amd64] http://mirror.ehv.weppel.nl/mariadb/repo/10.4/debian buster main'
    DEBIAN_FRONTEND=noninteractive apt-get -y -q update
    DEBIAN_FRONTEND=noninteractive apt-get -y -q install mariadb-server
    DEBIAN_FRONTEND=noninteractive apt-get -y -q autoclean
    DEBIAN_FRONTEND=noninteractive apt-get -y -q autoremove
    rm -rf /var/lib/apt/lists/*
elif [ -f /usr/bin/yum ] ; then
    cat << EOF > /etc/yum.repos.d/mariadb.repo
[mariadb]
name = MariaDB
baseurl=http://yum.mariadb.org/10.4/centos8-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF
    yum install -q -y boost-program-options
    yum --disablerepo=AppStream install -q -y MariaDB-server MariaDB-client
    echo cleaning up
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

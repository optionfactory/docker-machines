#!/bin/bash -e

groupadd --system --gid 950 docker-machines
useradd --system --create-home --gid docker-machines --uid 950 mysql


cat <<-'EOF' >  /etc/apt/keyrings/mariadb.asc
-----BEGIN PGP ARMORED FILE-----

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
=9mKo
-----END PGP ARMORED FILE-----
EOF

cat <<-'EOF' >  /etc/apt/keyrings/mariadb-maxscale.asc
-----BEGIN PGP ARMORED FILE-----

AAAAIAEBAAJLQlhmAAAAAGiZ1YdomdWHAAAAAAAAAAAAAAMbAgEAAAAAAF4AAAKp
AAEAHExHD//vxNPcWXeGVc4aPdXjyU9JAAAAIAAAAAAAAAABAAwAAAF+AAAAOAAA
AAAAAQAEAAAAAAAAAAAAAAAAAAAAAGiZ1ZYAAAAAmQENBFSTDbABCADuZ2k4NIsm
hrSyAw/49GQugqPF40P0ldkTPkKDx8b6eNFtPFJbsyw9yKqUEIS+9eFtIEMLLR4C
IHMM56adZe5q5Wp7g/+rnHgTuefVWfMg42Vaxdk8lTQIN2Z3gSsj36DZTtO+Smxi
xFfxHb2YESUvgVzeWIaFBKZCV4JdumniI02RCAPuqxIHKYmhwuqQSpzIAuZQEVvM
qSwFBUOr+CSf3+YzQ/PmFqldlQOQKbSE6G2H7E1mMhRBI07uryo1gDSM42DSFcZ+
eQCzCHQrCNC+2TtBrPkmPNU7TpngtjBthjwF/qJVVX8/q+syv524E1MtO+uXwf4P
vrFJ537SkfdHABEBAAGwDAAAZ3BnAQAAAAAAALQ4TWFyaWFEQiBFbnRlcnByaXNl
IFNpZ25pbmcgS2V5IDxzaWduaW5nLWtleUBtYXJpYWRiLmNvbT6wDAAAZ3BnAgAA
AAAAAIkBOAQTAQIAIgUCVJMNsAIbAwYLCQgHAwIGFQgCCQoLBBYCAwECHgECF4AA
CgkQzho91ePJT0m1rggAp8pIwuvPKmq0eWgiTpI0Fa7nPtxmjP/DJPLF0/BmYrCc
k6LbeqPvrXY8eBi75wWRbLCw352cM2va0u/RiQHR6rIZOLelfBqkyvDhtiByZFyh
tMQElE1ld/qCwNg28OCC5oFmcZ3B055hMfsdgxlFk7IX8K6gTBctJLCo3ljJxUsz
oG00VtWe891OHJvHWVjQA+mzUG2QWlw1JPxTkxaRsF6gew0f8ugDKSatovqKw9IE
1ucoXUrDGrB6T+WAnM7TjZfRbdPBIIJM4cEEs3T/kdHiOrn/8JwfRtp5BkMR7F3t
aHNVKjhEKXSYD4RL+JZBT+IswdSMf8eGI4ZZF2ahs7AGAANncGcA1WzDlvf0MpYg
PRcr3t3LUjuipLU=
=MjGp
-----END PGP ARMORED FILE-----
EOF

cat <<-'EOF' > /etc/apt/preferences.d/mariadb.pref
Package: *
Pin: origin dlm.mariadb.com
Pin-Priority: 1000
EOF
        
cat <<-EOF > /etc/apt/sources.list.d/mariadb.list
deb [arch=amd64 signed-by=/etc/apt/keyrings/mariadb.asc] https://dlm.mariadb.com/repo/mariadb-server/${MARIA_DB_VERSION}/repo/${DISTRIB_ID} ${DISTRIB_CODENAME} main
deb [arch=amd64 signed-by=/etc/apt/keyrings/mariadb-maxscale.asc] https://dlm.mariadb.com/repo/maxscale/latest/apt ${DISTRIB_CODENAME} main
EOF



DEBIAN_FRONTEND=noninteractive apt-get -y -q update 
DEBIAN_FRONTEND=noninteractive apt-get -y -q install software-properties-common mariadb-server
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
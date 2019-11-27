#!/bin/bash -e

groupadd -r postgres --gid=900
useradd -r -m -g postgres --uid=900 postgres

if [  -f /usr/bin/apt-get ] ; then
    DEBIAN_FRONTEND=noninteractive apt-get -y -q update
    DEBIAN_FRONTEND=noninteractive apt-get install -y -q curl gnupg
    curl -# -L https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
    if [ -f /etc/lsb-release ]; then
        echo 'deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main' > /etc/apt/sources.list.d/pgdg.list
    else
        echo 'deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main' > /etc/apt/sources.list.d/pgdg.list
    fi
    DEBIAN_FRONTEND=noninteractive apt-get -y -q update
    DEBIAN_FRONTEND=noninteractive apt-get install -y -q postgresql-common postgresql-11 postgresql-contrib-11
    rm -rf /var/lib/apt/lists/*
elif [ -f /usr/bin/yum ] ; then
    if rpm -q centos-release | grep release-8; then
        yum module disable -q -y postgresql
        #we need locales
        yum install -q -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm
        yum install -q -y glibc-locale-source
    else
        yum install -q -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
    fi
    yum install -q -y postgresql11 postgresql11-server postgresql11-contrib
    yum clean all
    rm -rf /var/cache/yum
else
    echo "unknown or missing package manager"
    exit 1
fi

if [ -f /etc/postgresql-common/createcluster.conf ]; then
    sed -ri 's/#(create_main_cluster) .*$/\1 = false/' /etc/postgresql-common/createcluster.conf
fi
mkdir -p /var/run/postgresql
chown -R postgres /var/run/postgresql
localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

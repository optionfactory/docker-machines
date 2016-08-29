#!/bin/bash -e

groupadd -r postgres --gid=900 
useradd -r -m -g postgres --uid=900 postgres

if [  -f /usr/bin/apt-get ] ; then
    apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8
    if [ -f /etc/lsb-release ]; then
        echo 'deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main' 9.5 > /etc/apt/sources.list.d/pgdg.list
    else
        echo 'deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main' 9.5 > /etc/apt/sources.list.d/pgdg.list
    fi
    DEBIAN_FRONTEND=noninteractive apt-get -y -q update
    DEBIAN_FRONTEND=noninteractive apt-get install -y -q postgresql-common postgresql-9.5 postgresql-contrib-9.5
    rm -rf /var/lib/apt/lists/*
elif [ -f /usr/bin/zypper ] ; then
    #https://software.opensuse.org/download.html?project=server%3Adatabase%3Apostgresql&package=postgresql
    zypper -n -q addrepo http://download.opensuse.org/repositories/server:database:postgresql/openSUSE_13.2/server:database:postgresql.repo
    zypper -n -q --gpg-auto-import-keys refresh
    zypper -n -q install timezone postgresql95 postgresql95-server postgresql95-contrib
    zypper -n -q clean --all
elif [ -f /usr/bin/yum ] ; then
    yum install -q -y http://yum.postgresql.org/9.5/redhat/rhel-7-x86_64/pgdg-redhat95-9.5-2.noarch.rpm
    yum install -q -y postgresql95 postgresql95-server postgresql95-contrib
    yum clean all
else 
    echo "unknown or missing package manager"
    exit 1    
fi

if [ -f /etc/postgresql-common/createcluster.conf ]; then
    sed -ri 's/#(create_main_cluster) .*$/\1 = false/' /etc/postgresql-common/createcluster.conf
fi

mkdir -p /var/run/postgresql 
chown -R postgres /var/run/postgresql

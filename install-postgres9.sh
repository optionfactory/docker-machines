#!/bin/bash -e

groupadd -r postgres --gid=900
useradd -r -m -g postgres --uid=900 postgres

if [  -f /usr/bin/apt-get ] ; then
    DEBIAN_FRONTEND=noninteractive apt-get -y -q update
    DEBIAN_FRONTEND=noninteractive apt-get install -y -q curl gnupg
    curl -# -L https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
    if [ -f /etc/lsb-release ]; then
        echo 'deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main' 9.6 > /etc/apt/sources.list.d/pgdg.list
    else
        echo 'deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main' 9.6 > /etc/apt/sources.list.d/pgdg.list
    fi
    DEBIAN_FRONTEND=noninteractive apt-get -y -q update
    DEBIAN_FRONTEND=noninteractive apt-get install -y -q postgresql-common postgresql-9.6 postgresql-contrib-9.6
    rm -rf /var/lib/apt/lists/*
elif [ -f /usr/bin/zypper ] ; then
    #https://software.opensuse.org/download.html?project=server%3Adatabase%3Apostgresql&package=postgresql
    #zypper -n -q addrepo https://download.postgresql.org/pub/repos/zypp/repo/pgdg-sles-96.repo
    #zypper -n -q --gpg-auto-import-keys refresh
    zypper -n -q install glibc-i18ndata timezone postgresql96 postgresql96-server postgresql96-contrib
    zypper -n -q clean --all
elif [ -f /usr/bin/yum ] ; then
    yum install -q -y http://yum.postgresql.org/9.6/redhat/rhel-7-x86_64/pgdg-redhat96-9.6-3.noarch.rpm
    yum install -q -y postgresql96 postgresql96-server postgresql96-contrib
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

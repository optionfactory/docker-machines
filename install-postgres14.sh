#!/bin/bash -e

groupadd --system --gid 20000 docker-machines
useradd --system --create-home --gid docker-machines --uid 20002 postgres


case "${DISTRIB_LABEL}" in
    debian*|ubuntu*)
        DEBIAN_FRONTEND=noninteractive apt-get -y -q update
        DEBIAN_FRONTEND=noninteractive apt-get install -y -q curl gnupg
        curl -# -L https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
        echo "deb http://apt.postgresql.org/pub/repos/apt/ ${DISTRIB_CODENAME}-pgdg main" > /etc/apt/sources.list.d/pgdg.list
        DEBIAN_FRONTEND=noninteractive apt-get -y -q update
        DEBIAN_FRONTEND=noninteractive apt-get install -y -q postgresql-common postgresql-14 postgresql-contrib-14
        rm -rf /var/lib/apt/lists/*
    ;;
    centos8|rocky8)
        yum module disable -q -y postgresql
        #we need locales
        yum install -q -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm
        yum install -q -y glibc-locale-source
        yum install -q -y postgresql14 postgresql14-server postgresql14-contrib
        yum clean all
        rm -rf /var/cache/yum
    ;;
    *)
    echo "distribution ${DISTRIB_LABEL} not supported"
    exit 1
    ;;
esac

if [ -f /etc/postgresql-common/createcluster.conf ]; then
    sed -ri 's/#(create_main_cluster) .*$/\1 = false/' /etc/postgresql-common/createcluster.conf
fi

mkdir -p /var/run/postgresql
chown -R postgres:docker-machines /var/run/postgresql
localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

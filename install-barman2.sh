#!/bin/bash -e

groupadd --system --gid 950 docker-machines
groupadd --system --gid 950 barman
useradd --system --create-home --gid docker-machines --uid 950 barman

case "${DISTRIB_LABEL}" in
    debian*|ubuntu*)
        DEBIAN_FRONTEND=noninteractive apt-get -y -q update
        DEBIAN_FRONTEND=noninteractive apt-get install -y -q curl
        curl -# -L https://www.postgresql.org/media/keys/ACCC4CF8.asc > /etc/apt/trusted.gpg.d/barman.asc
        echo "deb http://apt.postgresql.org/pub/repos/apt/ ${DISTRIB_CODENAME}-pgdg main" > /etc/apt/sources.list.d/pgdg.list
        DEBIAN_FRONTEND=noninteractive apt-get -y -q update
        DEBIAN_FRONTEND=noninteractive apt-get install -y -q barman
        rm -rf /var/lib/apt/lists/*
    ;;
    rocky9)
        yum module disable -q -y postgresql
        #we need locales
        yum install -q -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm
        yum install -q -y glibc-locale-source
        yum install -q -y barman
        yum clean all
        rm -rf /var/cache/yum
    ;;
    *)
    echo "distribution ${DISTRIB_LABEL} not supported"
    exit 1
    ;;
esac

cat <<-'EOF' > /etc/barman.conf
[barman]
barman_user = barman
configuration_files_directory = /etc/barman.d
barman_home = /var/lib/barman

;barman_lock_directory = /var/run/barman
log_level = INFO
compression = gzip
;bandwidth_limit = 4000
;parallel_jobs = 1
;immediate_checkpoint = false
;network_compression = false
;basebackup_retry_times = 0
;basebackup_retry_sleep = 30
;check_timeout = 30
;last_backup_maximum_age =
;minimum_redundancy = 1
;retention_policy =
;retention_policy = REDUNDANCY 2
;retention_policy = RECOVERY WINDOW OF 4 WEEKS
EOF



chown -R barman:docker-machines /var/lib/barman

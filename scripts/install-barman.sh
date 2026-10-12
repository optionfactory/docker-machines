#!/bin/bash -e

groupadd --system --gid 950 docker-machines
useradd --system --create-home --gid docker-machines --uid 950 barman

DEBIAN_FRONTEND=noninteractive apt-get -y -q update
DEBIAN_FRONTEND=noninteractive apt-get install -y -q --no-install-recommends curl
install -d -m 0755 /etc/apt/keyrings
curl -# -L https://www.postgresql.org/media/keys/ACCC4CF8.asc > /etc/apt/keyrings/pgdg.asc
echo "deb [signed-by=/etc/apt/keyrings/pgdg.asc] https://apt.postgresql.org/pub/repos/apt/ ${DISTRIB_CODENAME}-pgdg main" > /etc/apt/sources.list.d/pgdg.list
DEBIAN_FRONTEND=noninteractive apt-get -y -q update
DEBIAN_FRONTEND=noninteractive apt-get install -y -q --no-install-recommends barman postgresql-client openssh-client python3-lz4 python3-zstandard procps
DEBIAN_FRONTEND=noninteractive apt-get -y -q purge --auto-remove curl
rm -rf /var/lib/apt/lists/*

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

cat <<'EOF' > /barman
#!/bin/bash
trap 'exit 0' TERM INT
while :
do
    setpriv --reuid=barman --regid=docker-machines --init-groups --no-new-privs -- barman cron || echo "barman cron failed (exit $?), retrying in 60s" >&2
    sleep 60 &
    wait $!
done
EOF

chmod 750 /barman

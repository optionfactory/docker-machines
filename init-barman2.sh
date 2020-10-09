#!/bin/bash -e

if [ $# -eq 0 ]; then
    while :
    do
        gosu barman:docker-machines barman cron
        sleep 60
    done
fi

exec "$@"

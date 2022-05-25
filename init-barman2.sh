#!/bin/bash -e
while :
do
    gosu barman:docker-machines barman cron
    sleep 60
done

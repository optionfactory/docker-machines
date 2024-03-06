#!/bin/bash -e
while :
do
    gosu barman:barman barman cron
    sleep 60
done

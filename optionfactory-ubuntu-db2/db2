#!/bin/bash -e


if [ "$1" == "init" ]; then
    if [ "$(id -u)" != "0" ]; then
        echo "must be root to init"
        exit 1
    fi

    if [ ! -d /home/db2inst1 ]; then
        mkdir -p /home/{db2inst1,db2fenc1,dasusr1}

    else
        echo "home already ok"
    fi
    touch /home/{db2inst1,db2fenc1,dasusr1}/.profile
    chown -R db2inst1:db2iadm1 /home/db2inst1
    chown -R db2fenc1:db2fadm1 /home/db2fenc1
    chown -R dasusr1:dasadm1 /home/dasusr1



    if [ ! -f /home/db2inst1/sqllib/adm/db2start ]; then
        /opt/ibm/db2/instance/dascrt -u dasusr1
        /opt/ibm/db2/instance/db2icrt -p 50000 -u db2fenc1 db2inst1
    else
        echo "db already initialized"
    fi

    exit 0
fi

if [ $# -eq 0 ]; then    
    echo "starting db2"
    /home/db2inst1/sqllib/adm/db2start
    echo "creating db (using another shell: bugs! bugs everywhere!)"
    set +e
    bash -c 'sleep 2;/home/db2inst1/sqllib/bin/db2 -v CREATE DATABASE sample'
    set -e
    tail -F /home/db2inst1/sqllib/db2dump/db2diag.log
fi

exec "$@"
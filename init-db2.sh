#!/bin/bash -e

if [ "${1}" == "_sql_init_d" ]; then
    for f in /sql-init.d/*; do
        case "$f" in
            *.sh)     echo "$0: running $f"; . "$f" ;;
            *.sql)    echo "$0: running $f"; /home/db2inst1/sqllib/bin/db2 -tvmf $f; echo ;;
            /sql-init.d/*) echo "no scripts found in /sql-init.d/" ;; 
            *)        echo "$0: ignoring $f" ;;
        esac
    done    		
    exit 0
fi

if [ $# -eq 0 ]; then    
	echo "fixing permissions"
	chown -R db2inst1:db2iadm1 /home/db2inst1
	chown -R db2inst1:db2iadm1 /sql-init.d/

	if [ ! -d /home/db2inst1/sqllib ]; then
		echo "initializing database instance"
		/opt/ibm/db2/instance/db2icrt -p 50000 -u db2fenc1 db2inst1	
	fi
    echo "starting db2"
	. /home/db2inst1/sqllib/db2profile
    gosu db2inst1 /home/db2inst1/sqllib/adm/db2start

    if [ ! -d /home/db2inst1/db2inst1 ]; then
		echo "initializing database instance"
    	#weird behaviour from db, doesn't work if invoked in this shell
    	#http://www.44342.com/DATABASE-f1257-t11239-p1.htm
    	gosu db2inst1 bash /db2 _sql_init_d
    fi

    tail -c +1 -F /home/db2inst1/sqllib/db2dump/db2diag.log -n 10000 &
    PIDOF_TAIL=$!
    PIDOF_DB2=$(pidof db2sysc)
    while kill -0 "${PIDOF_DB2}"; do
        sleep 2
    done    
    kill ${PIDOF_TAIL}    
fi

exec "$@"
#!/bin/bash -e



if [ -f /usr/bin/apt-get  ]; then
    DEBIAN_FRONTEND=noninteractive apt-get -y -q update
    DEBIAN_FRONTEND=noninteractive apt-get install -y -q supervisor
    DEBIAN_FRONTEND=noninteractive apt-get -y -q autoclean
    DEBIAN_FRONTEND=noninteractive apt-get -y -q autoremove
    rm -rf /var/lib/apt/lists/*
elif [ -f /usr/bin/zypper ] ; then
    zypper -n -q install python2-pip
    pip install supervisor
    zypper -n -q remove python2-pip
    zypper -n -q clean --all
elif [ -f /usr/bin/yum ] ; then
    yum install -q -y python-setuptools
    easy_install supervisor
    yum remove -q -y python-setuptools
    yum clean all
    rm -rf /var/cache/yum
else
    echo "unknown or missing package manager"
    exit 1
fi


mkdir -p /etc/supervisor/

cat <<-'EOF' > /etc/supervisor/supervisord.conf
[unix_http_server]
file=/var/run/supervisor.sock   ; (the path to the socket file)
chmod=0700                       ; sockef file mode (default 0700)

[supervisord]
logfile=/dev/fd/1
logfile_maxbytes=0
pidfile=/var/run/supervisord.pid ; (supervisord pidfile;default supervisord.pid)
childlogdir=/var/log/supervisor            ; ('AUTO' child log dir, default $TEMP)

; the below section must remain in the config file for RPC
; (supervisorctl/web interface) to work, additional interfaces may be
; added by defining them in separate rpcinterface: sections
[rpcinterface:supervisor]
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface

[supervisorctl]
serverurl=unix:///var/run/supervisor.sock ; use a unix:// URL  for a unix socket

[program:zookeeper]
command=/opt/zookeeper/bin/zkServer.sh start-foreground
stdout_logfile=/dev/fd/1
stdout_logfile_maxbytes=0
stderr_logfile=/dev/fd/1
stderr_logfile_maxbytes=0
autostart=true
autorestart=true


[program:kafka]
command=/opt/kafka/bin/kafka-run-class.sh -name kafkaServer kafka.Kafka /opt/kafka/config/server.properties
stdout_logfile=/dev/fd/1
stdout_logfile_maxbytes=0
stderr_logfile=/dev/fd/1
stderr_logfile_maxbytes=0
autostart=true
autorestart=true

EOF

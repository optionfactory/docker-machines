#!/bin/bash -e

DEBIAN_FRONTEND=noninteractive apt-get -y -q update
DEBIAN_FRONTEND=noninteractive apt-get install -y -q supervisor
rm -rf /var/lib/apt/lists/*
DEBIAN_FRONTEND=noninteractive apt-get -y -q clean



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

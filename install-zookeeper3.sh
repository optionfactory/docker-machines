#!/bin/bash -e


mkdir -p /opt/zookeeper/
mkdir -p /var/lib/zookeeper/
cp -R /tmp/zookeeper*/* /opt/zookeeper

cat <<-'EOF' > /opt/zookeeper/conf/log4j.properties
    log4j.rootLogger=INFO, CONSOLE
    log4j.appender.CONSOLE=org.apache.log4j.ConsoleAppender
    log4j.appender.CONSOLE.Threshold=INFO
    log4j.appender.CONSOLE.layout=org.apache.log4j.PatternLayout
    log4j.appender.CONSOLE.layout.ConversionPattern=[%d][zookeeper][node:NODE_ID][%p] %m (%c)%n
EOF

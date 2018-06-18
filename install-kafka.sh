#!/bin/bash -e

mkdir -p /var/lib/kafka/
mkdir -p /opt/kafka/

cp -R /tmp/kafka*/* /opt/kafka

cat <<-'EOF' > /opt/kafka/config/log4j.properties
    log4j.rootLogger=INFO, stdout

    log4j.appender.stdout=org.apache.log4j.ConsoleAppender
    log4j.appender.stdout.layout=org.apache.log4j.PatternLayout
    log4j.appender.stdout.layout.ConversionPattern=[%d][kafka][node:NODE_ID][%p] %m (%c)%n

    # Change the two lines below to adjust ZK client logging
    log4j.logger.org.I0Itec.zkclient.ZkClient=INFO
    log4j.logger.org.apache.zookeeper=INFO
    log4j.logger.kafka=INFO
    log4j.logger.org.apache.kafka=INFO
    # Change to DEBUG or TRACE to enable request logging
    log4j.logger.kafka.request.logger=WARN
    # Uncomment the lines below and change log4j.logger.kafka.network.RequestChannel$ to TRACE for additional output related to the handling of requests
    #log4j.logger.kafka.network.Processor=TRACE
    #log4j.logger.kafka.server.KafkaApis=TRACE
    log4j.logger.kafka.network=WARN
    log4j.logger.kafka.controller=TRACE
    log4j.logger.kafka.log.LogCleaner=INFO
    log4j.logger.state.change.logger=TRACE
    # Access denials are logged at INFO level, change to DEBUG to also log allowed accesses
    log4j.logger.kafka.authorizer.logger=INFO
EOF

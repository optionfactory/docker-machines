#!/bin/bash -e

if [ $# -ne 0 ]; then
    exec "$@"
fi


# Optional ENV variables:
# * ZOOKEEPER_ID: the node id
# * ZOOKEEPER_SERVERS: (e.g: 172.17.0.1:2888:3888,172.17.0.1:2889:3889,172.17.0.1:2890:3890)

if [ -z "$ZOOKEEPER_ID" ]; then
    echo "ZOOKEEPER_ID env variable is missing"
    exit 1
fi

echo "zookeeper id: $ZOOKEEPER_ID"
echo "$ZOOKEEPER_ID" > /var/lib/zookeeper/myid
sed -r -i "s/NODE_ID/$ZOOKEEPER_ID/g" /opt/zookeeper/conf/log4j.properties

echo "tickTime=2000" > /opt/zookeeper/conf/zoo.cfg
echo "initLimit=10"  >> /opt/zookeeper/conf/zoo.cfg
echo "syncLimit=5"  >> /opt/zookeeper/conf/zoo.cfg
echo "dataDir=/var/lib/zookeeper"  >> /opt/zookeeper/conf/zoo.cfg
echo "clientPort=2181"  >> /opt/zookeeper/conf/zoo.cfg

if [ ! -z "$ZOOKEEPER_SERVERS" ]; then
    echo "zookeeper servers: $ZOOKEEPER_SERVERS"
    IFS=',' read -r -a servers <<< $ZOOKEEPER_SERVERS
    for index in "${!servers[@]}"; do
        IFS=':' read -r -a ipAndPorts <<< "${servers[index]}"
        ip="${ipAndPorts[0]}"
        peersPort="${ipAndPorts[1]}"
        electionPort="${ipAndPorts[2]}"
        myIp="${ip}"
        if [ "${ZOOKEEPER_ID}" -eq "$((index+1))" ]; then
            myIp="0.0.0.0"
        fi
        echo "zookeeper servers: server.$((index +1))=${myIp}:${peersPort}:${electionPort}"
        echo "server.$((index +1))=${myIp}:${peersPort}:${electionPort}" >> /opt/zookeeper/conf/zoo.cfg
    done
fi

# Optional ENV variables:
# * KAFKA_BROKER_ID: the broker id
# * KAFKA_BROKER_ID_GENERATION_ENABLE: (true|false)
# * KAFKA_ZOOKEEPER_CONNECT: comma separated list of zookeeper hosts, e.g: localhost:2181,172.17.0.1:2182
# * KAFKA_ADVERTISED_HOST: the external ip for the container, e.g. `docker-machine ip \`docker-machine active\``
# * KAFKA_ADVERTISED_PORT: the external port for Kafka, e.g. 9092
# * KAFKA_ZK_CHROOT: the zookeeper chroot that's used by Kafka (without / prefix), e.g. "kafka"
# * KAFKA_LOG_RETENTION_HOURS: the minimum age of a log file in hours to be eligible for deletion (default is 168, for 1 week)
# * KAFKA_LOG_RETENTION_BYTES: configure the size at which segments are pruned from the log, (default is 1073741824, for 1GB)
# * KAFKA_NUM_PARTITIONS: configure the default number of log partitions per topic


###### KAFKA ##############

# Configure advertised host/port if we run in helios
if [ ! -z "$HELIOS_PORT_kafka" ]; then
    ADVERTISED_HOST=`echo $HELIOS_PORT_kafka | cut -d':' -f 1 | xargs -n 1 dig +short | tail -n 1`
    ADVERTISED_PORT=`echo $HELIOS_PORT_kafka | cut -d':' -f 2`
fi

echo "" >> /opt/kafka/config/server.properties


echo "log dirs: /var/lib/kafka/"
sed -r -i "s/(log.dirs)=(.*)/\1=\/var\/lib\/kafka\//g" /opt/kafka/config/server.properties

#Set the broker id
if [ ! -z "$KAFKA_BROKER_ID" ]; then
     echo "broker id: $KAFKA_BROKER_ID"
     sed -r -i "s/(broker.id)=(.*)/\1=$KAFKA_BROKER_ID/g" /opt/kafka/config/server.properties
     sed -r -i "s/NODE_ID/$KAFKA_BROKER_ID/g" /opt/kafka/config/log4j.properties     
fi

if [ ! -z "$KAFKA_BROKER_ID_GENERATION_ENABLE" ]; then
    echo "broker id generation enable: $KAFKA_BROKER_ID_GENERATION_ENABLE"
    echo "broker.id.generation.enable=$KAFKA_BROKER_ID_GENERATION_ENABLE" >> /opt/kafka/config/server.properties
fi

#zookeeper connect
if [ ! -z "$KAFKA_ZOOKEEPER_CONNECT" ]; then
    echo "zookeeper connect: $KAFKA_ZOOKEEPER_CONNECT"
    sed -r -i "s/(zookeeper.connect)=(.*)/\1=$KAFKA_ZOOKEEPER_CONNECT/g" /opt/kafka/config/server.properties
fi

# Set the external host and port
if [ ! -z "$KAFKA_ADVERTISED_HOST" ]; then
    echo "advertised host: $KAFKA_ADVERTISED_HOST"
    if grep -q "^advertised.host.name" /opt/kafka/config/server.properties; then
        sed -r -i "s/#(advertised.host.name)=(.*)/\1=$KAFKA_ADVERTISED_HOST/g" /opt/kafka/config/server.properties
    else
        echo "advertised.host.name=$KAFKA_ADVERTISED_HOST" >> /opt/kafka/config/server.properties
    fi
fi
if [ ! -z "$KAFKA_ADVERTISED_PORT" ]; then
    echo "advertised port: $KAFKA_ADVERTISED_PORT"
    if grep -q "^advertised.port" /opt/kafka/config/server.properties; then
        sed -r -i "s/#(advertised.port)=(.*)/\1=$KAFKA_ADVERTISED_PORT/g" /opt/kafka/config/server.properties
    else
        echo "advertised.port=$KAFKA_ADVERTISED_PORT" >> /opt/kafka/config/server.properties
    fi
fi
# Set the zookeeper chroot
if [ ! -z "$KAFKA_ZK_CHROOT" ]; then
    # wait for zookeeper to start up
    until /usr/share/zookeeper/bin/zkServer.sh status; do
      sleep 0.1
    done

    # create the chroot node
    echo "create /$KAFKA_ZK_CHROOT \"\"" | /usr/share/zookeeper/bin/zkCli.sh || {
        echo "can't create chroot in zookeeper, exit"
        exit 1
    }

    # configure kafka
    sed -r -i "s/(zookeeper.connect)=(.*)/\1=localhost:2181\/$KAFKA_ZK_CHROOT/g" /opt/kafka/config/server.properties
fi


# Allow specification of log retention policies
if [ ! -z "$KAFKA_LOG_RETENTION_HOURS" ]; then
    echo "log retention hours: $KAFKA_LOG_RETENTION_HOURS"
    sed -r -i "s/(log.retention.hours)=(.*)/\1=$KAFKA_LOG_RETENTION_HOURS/g" /opt/kafka/config/server.properties
fi
if [ ! -z "$KAFKA_LOG_RETENTION_BYTES" ]; then
    echo "log retention bytes: $LOG_RETENTION_BYTES"
    sed -r -i "s/#(log.retention.bytes)=(.*)/\1=$KAFKA_LOG_RETENTION_BYTES/g" /opt/kafka/config/server.properties
fi

# Configure the default number of log partitions per topic
if [ ! -z "$KAFKA_NUM_PARTITIONS" ]; then
    echo "default number of partition: $KAFKA_NUM_PARTITIONS"
    sed -r -i "s/(num.partitions)=(.*)/\1=$KAFKA_NUM_PARTITIONS/g" /opt/kafka/config/server.properties
fi

# Enable/disable auto creation of topics
if [ ! -z "$KAFKA_AUTO_CREATE_TOPICS" ]; then
    echo "auto.create.topics.enable: $KAFKA_AUTO_CREATE_TOPICS"
    echo "auto.create.topics.enable=$KAFKA_AUTO_CREATE_TOPICS" >> /opt/kafka/config/server.properties
fi

# Run Kafka
export KAFKA_LOG4J_OPTS="-Dlog4j.configuration=file:/opt/kafka/config/log4j.properties"
export KAFKA_HEAP_OPTS="${KAFKA_JAVA_OPTS:--Xmx1G -Xms1G}"




exec supervisord -n

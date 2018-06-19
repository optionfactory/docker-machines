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

exec /opt/zookeeper/bin/zkServer.sh start-foreground

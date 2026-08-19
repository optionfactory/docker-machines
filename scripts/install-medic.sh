#!/bin/bash -e

echo "Installing medic tools"

DEBIAN_FRONTEND=noninteractive apt-get -y -q update 
DEBIAN_FRONTEND=noninteractive apt-get -y -q install \
    bridge-utils \
    curl \
    dhcping \
    inetutils-tools \
    inetutils-telnet \
    iputils-ping \
    iputils-arping \
    iputils-tracepath \
    iputils-clockdiff \
    iperf \
    iproute2 \
    ipset \
    iptables \
    iptraf-ng \
    jq \
    ldap-utils \
    mtr \
    netcat-openbsd \
    net-tools \
    netgen \
    nmap \
    openssl \
    socat \
    snmp \
    strace \
    tcpdump \
    tcptraceroute \
    termshark \
    tshark
DEBIAN_FRONTEND=noninteractive apt-get -y -q autoclean
DEBIAN_FRONTEND=noninteractive apt-get -y -q autoremove
rm -rf /var/lib/apt/lists/*



FROM debian:jessie
MAINTAINER Roberto Ferranti


COPY install-ps1.sh /etc/bash.bashrc
RUN DEBIAN_FRONTEND=noninteractive apt-get update \
   && DEBIAN_FRONTEND=noninteractive apt-get install -y -q tar curl wget unzip \
   && DEBIAN_FRONTEND=noninteractive apt-get -y -q autoclean \
   && DEBIAN_FRONTEND=noninteractive apt-get -y -q autoremove

COPY install-spawn-and-tail.sh /tmp/install-spawn-and-tail.sh
RUN /tmp/install-spawn-and-tail.sh && rm /tmp/install-spawn-and-tail.sh

COPY install-jdk.sh /tmp/install-jdk.sh
RUN /tmp/install-jdk.sh && rm /tmp/install-jdk.sh
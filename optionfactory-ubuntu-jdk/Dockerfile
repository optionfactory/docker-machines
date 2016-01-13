FROM ubuntu:15.10
MAINTAINER Roberto Ferranti
COPY ps1.sh /etc/bash.bashrc
COPY log.sh /etc/profile.d/log.sh
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q tar curl \
   && DEBIAN_FRONTEND=noninteractive apt-get -y -q autoclean \
   && DEBIAN_FRONTEND=noninteractive apt-get -y -q autoremove


COPY Docker-bootstrap.sh /tmp/Docker-bootstrap.sh
RUN /tmp/Docker-bootstrap.sh && rm /tmp/Docker-bootstrap.sh
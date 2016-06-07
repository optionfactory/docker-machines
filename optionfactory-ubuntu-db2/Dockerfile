FROM ubuntu:16.04
MAINTAINER Roberto Ferranti


COPY install-ps1.sh /etc/bash.bashrc



RUN echo "deps" \
   && DEBIAN_FRONTEND=noninteractive dpkg --add-architecture i386 \
   && DEBIAN_FRONTEND=noninteractive apt-get -y -q update \
   && DEBIAN_FRONTEND=noninteractive apt-get -y -q install tar curl wget unzip libpam0g:i386 libaio1 libstdc++6 lib32stdc++6 binutils file libxml2 \
   && DEBIAN_FRONTEND=noninteractive apt-get -y -q install strace net-tools \
   && DEBIAN_FRONTEND=noninteractive apt-get -y -q autoclean \
   && DEBIAN_FRONTEND=noninteractive apt-get -y -q autoremove \
   && ln -s /lib/i386-linux-gnu/libpam.so.0 /lib/libpam.so.0 \
   && rm -rf /var/lib/apt/lists/*


COPY install-spawn-and-tail.sh /tmp/install-spawn-and-tail.sh
RUN /tmp/install-spawn-and-tail.sh && rm /tmp/install-spawn-and-tail.sh

# http://www.ibm.com/developerworks/downloads/im/db2express/
COPY v10.5_linuxx64_expc.tar.gz /tmp/
RUN tar xzf /tmp/v10.5_linuxx64_expc.tar.gz -C /tmp
COPY responses.rsp /tmp/responses.rsp

RUN /tmp/expc/db2setup -r /tmp/responses.rsp

RUN groupadd db2iadm1
RUN groupadd db2fadm1
RUN groupadd dasadm1
RUN useradd -g db2iadm1 -m -d /home/db2inst1 db2inst1
RUN useradd -g db2fadm1 -m -d /home/db2fenc1 db2fenc1
RUN useradd -g dasadm1 -m -d /home/dasusr1 dasusr1
RUN echo db2inst1:db2inst1 | chpasswd
RUN echo db2fenc1:db2fenc1 | chpasswd
RUN echo dasusr1:dasusr1 | chpasswd

RUN /opt/ibm/db2/instance/dascrt -u dasusr1
RUN /opt/ibm/db2/instance/db2icrt -p 50000 -u db2fenc1 db2inst1


RUN rm -rf /tmp/*

USER db2inst1
EXPOSE 50000
COPY db2 /db2
ENTRYPOINT ["/db2"]
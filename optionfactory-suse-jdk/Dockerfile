FROM opensuse:13.2
MAINTAINER Roberto Ferranti

COPY install-ps1.sh /etc/bash.bashrc
RUN zypper -n -q install tar curl && zypper -n -q clean --all

COPY install-spawn-and-tail.sh /tmp/install-spawn-and-tail.sh
RUN /tmp/install-spawn-and-tail.sh && rm /tmp/install-spawn-and-tail.sh

COPY install-jdk.sh /tmp/install-jdk.sh
RUN /tmp/install-jdk.sh && rm /tmp/install-jdk.sh
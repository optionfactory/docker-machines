FROM centos:centos7
MAINTAINER Roberto Ferranti <roberto@optionfactory.net>

#COPY ps1.sh /etc/bash.bashrc
RUN yum install -q -y tar && yum clean all
COPY install-ps1.sh /etc/profile.d/ps1.sh

COPY install-spawn-and-tail.sh /tmp/install-spawn-and-tail.sh
RUN /tmp/install-spawn-and-tail.sh && rm /tmp/install-spawn-and-tail.sh

COPY install-jdk.sh /tmp/install-jdk.sh
RUN /tmp/install-jdk.sh && rm /tmp/install-jdk.sh


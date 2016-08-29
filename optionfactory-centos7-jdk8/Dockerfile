FROM centos:centos7
MAINTAINER Roberto Ferranti <roberto@optionfactory.net>

COPY deps /tmp/
RUN cp /tmp/install-ps1.sh /etc/profile.d/ps1.sh
RUN /tmp/install-spawn-and-tail.sh
RUN /tmp/install-jdk.sh
RUN rm -rf /tmp/*
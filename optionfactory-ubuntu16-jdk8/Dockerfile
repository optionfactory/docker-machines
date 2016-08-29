FROM ubuntu:16.04
MAINTAINER Roberto Ferranti

COPY deps /tmp/
RUN cp /tmp/install-ps1.sh /etc/bash.bashrc
RUN /tmp/install-spawn-and-tail.sh
RUN /tmp/install-jdk.sh
RUN rm -rf /tmp/*
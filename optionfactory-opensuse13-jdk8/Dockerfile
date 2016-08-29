FROM opensuse:13.2
MAINTAINER Roberto Ferranti

COPY deps /tmp/
RUN cp /tmp/install-ps1.sh /etc/bash.bashrc.local
RUN /tmp/install-spawn-and-tail.sh
RUN /tmp/install-jdk.sh
RUN rm -rf /tmp/*
FROM optionfactory/ubuntu18-jdk8
MAINTAINER Lorenzo Caenazzo <lorenzo.caenazzo@optionfactory.net>

COPY deps /tmp/
RUN /tmp/install-riemann.sh
RUN cp /tmp/init-riemann.sh /riemann
RUN rm -rf /tmp/*

EXPOSE 5555 5556

ENTRYPOINT ["/riemann"]

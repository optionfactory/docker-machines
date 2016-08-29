FROM optionfactory/centos7-jdk8:latest

MAINTAINER Roberto Ferranti

COPY deps /tmp/

WORKDIR /opt/liberty
RUN /tmp/install-liberty.sh
RUN cp /tmp/init-liberty.sh /liberty
RUN rm -rf /tmp/*

USER liberty

#      http https debug
EXPOSE 9080  9443  8000

ENTRYPOINT ["/liberty"]

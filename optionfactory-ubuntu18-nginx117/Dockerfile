FROM optionfactory/ubuntu18:latest
MAINTAINER Roberto Ferranti <roberto@optionfactory.net>

COPY deps /tmp/

RUN /tmp/install-nginx117.sh
RUN cp /tmp/init-nginx117.sh /nginx

RUN rm -rf /tmp/*


ENTRYPOINT ["/nginx"]

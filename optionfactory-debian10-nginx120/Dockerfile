FROM optionfactory/debian10:latest
MAINTAINER Roberto Ferranti <roberto@optionfactory.net>

COPY deps /tmp/

RUN DISTRIB_LABEL=debian10 DISTRIB_ID=debian DISTRIB_RELEASE=10 DISTRIB_CODENAME=buster /tmp/install-nginx120.sh
RUN cp /tmp/init-nginx120.sh /nginx

RUN rm -rf /tmp/*


ENTRYPOINT ["/nginx"]

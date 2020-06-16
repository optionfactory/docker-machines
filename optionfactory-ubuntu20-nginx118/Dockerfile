FROM optionfactory/ubuntu20:latest
MAINTAINER Roberto Ferranti <roberto@optionfactory.net>

COPY deps /tmp/

RUN DISTRIB_LABEL=ubuntu20 DISTRIB_ID=ubuntu DISTRIB_RELEASE=20.04 DISTRIB_CODENAME=focal /tmp/install-nginx118.sh
RUN cp /tmp/init-nginx118.sh /nginx

RUN rm -rf /tmp/*


ENTRYPOINT ["/nginx"]

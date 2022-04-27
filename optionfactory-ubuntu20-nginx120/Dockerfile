FROM optionfactory/ubuntu20:latest
LABEL maintainer="Roberto Ferranti <roberto@optionfactory.net>"

COPY deps /tmp/

RUN DISTRIB_LABEL=ubuntu20 DISTRIB_ID=ubuntu DISTRIB_RELEASE=20.04 DISTRIB_CODENAME=focal /tmp/install-nginx120.sh
RUN cp /tmp/init-nginx120.sh /nginx

RUN rm -rf /tmp/*


ENTRYPOINT ["/nginx"]

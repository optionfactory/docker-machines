FROM optionfactory/rocky8:latest
LABEL maintainer="Roberto Ferranti <roberto@optionfactory.net>"

COPY deps /tmp/

RUN DISTRIB_LABEL=rocky8 DISTRIB_ID=rocky DISTRIB_RELEASE=8 DISTRIB_CODENAME=8 /tmp/install-nginx120.sh
RUN cp /tmp/init-nginx120.sh /nginx

RUN rm -rf /tmp/*


ENTRYPOINT ["/nginx"]

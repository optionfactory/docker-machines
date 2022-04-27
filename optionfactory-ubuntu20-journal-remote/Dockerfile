FROM optionfactory/ubuntu20:latest
LABEL maintainer="Roberto Ferranti <roberto@optionfactory.net>"

COPY deps /tmp/
RUN DISTRIB_LABEL=ubuntu20 DISTRIB_ID=ubuntu DISTRIB_RELEASE=20.04 DISTRIB_CODENAME=focal /tmp/install-journal-remote.sh
RUN cp /tmp/init-journal-remote.sh /journal-remote
RUN rm -rf /tmp/*

ENTRYPOINT ["/journal-remote"]

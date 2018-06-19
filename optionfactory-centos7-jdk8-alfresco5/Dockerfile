FROM optionfactory/centos7-jdk8:latest
#forked from: gui81/alfresco
MAINTAINER Francesco Degrassi <francesco.degrassi@optionfactory.net>

COPY deps /tmp/

RUN /tmp/install-alfresco5.sh /tmp/alfresco-*
RUN cp /tmp/init-alfresco5.sh /alfresco
RUN rm -rf /tmp/*

VOLUME /opt/alfresco/alf_data

EXPOSE 21 137 138 139 445 7070 8009 8080

WORKDIR /opt/alfresco

ENTRYPOINT ["/alfresco"]

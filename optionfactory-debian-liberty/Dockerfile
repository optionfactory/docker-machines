FROM optionfactory/debian-jdk:latest
MAINTAINER Roberto Ferranti


RUN mkdir -p /opt/liberty
WORKDIR /opt/liberty
RUN groupadd -r liberty 
RUN useradd -r -g liberty liberty
RUN wget --no-check-certificate "https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/wasdev/downloads/wlp/8.5.5.9/wlp-javaee7-8.5.5.9.zip" \
    && unzip wlp-javaee7-8.5.5.9.zip \
    && mv wlp/* . \
    && rm -rf wlp
COPY server.xml /opt/liberty/usr/servers/defaultServer/server.xml
RUN mkdir -p /opt/liberty/usr/servers/defaultServer/logs/
COPY liberty /liberty
RUN chown -R liberty:liberty /opt/liberty/
RUN bin/installUtility install jpa-2.0 --acceptLicense

USER liberty

#      http https debug
EXPOSE 9080  9443  8000

ENTRYPOINT ["/liberty"]
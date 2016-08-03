FROM optionfactory/centos-jdk:latest
#forked from: gui81/alfresco
MAINTAINER Francesco Degrassi <francesco.degrassi@optionfactory.net>

RUN yum install -q -y cups-libs dbus-glib fontconfig hostname libICE libSM libXext libXinerama libXrender grep patch && yum clean all

# install alfresco
COPY install-alfresco.sh /tmp/install-alfresco.sh
RUN /tmp/install-alfresco.sh && rm -f /tmp/install-alfresco.sh



# this is for LDAP configuration
RUN mkdir -p /opt/alfresco/tomcat/shared/classes/alfresco/extension/subsystems/Authentication/ldap/ldap1/
RUN mkdir -p /opt/alfresco/tomcat/shared/classes/alfresco/extension/subsystems/Authentication/ldap-ad/ldap1/
COPY alfresco-global.properties /opt/alfresco/tomcat/shared/classes/alfresco-global.propertie
COPY ldap-authentication.properties /opt/alfresco/tomcat/shared/classes/alfresco/extension/subsystems/Authentication/ldap/ldap1/ldap-authentication.properties
COPY ldap-ad-authentication.properties /opt/alfresco/tomcat/shared/classes/alfresco/extension/subsystems/Authentication/ldap-ad/ldap1/ldap-ad-authentication.properties

# install scripts
COPY alfresco /alfresco

#RUN mkdir -p /opt/alfresco/tomcat/webapps/ROOT
#COPY index.jsp /opt/alfresco/tomcat/webapps/ROOT/

VOLUME /opt/alfresco/alf_data

EXPOSE 21 137 138 139 445 7070 8009 8080

WORKDIR /opt/alfresco

RUN groupadd -r alfresco && useradd -r -g alfresco alfresco
COPY gosu /gosu
ENTRYPOINT ["/alfresco"]

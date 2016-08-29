mkdir -p /opt/liberty
groupadd -r liberty 
useradd -r -m -g liberty liberty
cp -R /tmp/liberty-*/* /opt/liberty

mkdir -p /opt/liberty/usr/servers/defaultServer/logs/

cat <<'EOF' > /opt/liberty/usr/servers/defaultServer/server.xml
<?xml version="1.0" encoding="UTF-8"?>
<server description="new server">

    <featureManager>
        <!--  <feature>javaee-7.0</feature> -->
        <feature>servlet-3.1</feature>
        <feature>beanValidation-1.1</feature>
        <feature>ssl-1.0</feature>
        <feature>jndi-1.0</feature>
        <feature>jca-1.7</feature>
        <feature>ejbPersistentTimer-3.2</feature>
        <feature>appSecurity-2.0</feature>
        <feature>j2eeManagement-1.1</feature>
        <feature>jdbc-4.1</feature>
        <feature>wasJmsServer-1.0</feature>
        <feature>jaxrs-2.0</feature>
        <feature>javaMail-1.5</feature>
        <feature>cdi-1.2</feature>
        <feature>jcaInboundSecurity-1.0</feature>
        <feature>jsp-2.3</feature>
        <feature>ejbLite-3.2</feature>
        <feature>managedBeans-1.0</feature>
        <feature>jsf-2.2</feature>
        <feature>ejbHome-3.2</feature>
        <feature>jaxws-2.2</feature>
        <feature>jsonp-1.0</feature>
        <feature>restConnector-1.0</feature>
        <feature>el-3.0</feature>
        <feature>jaxrsClient-2.0</feature>
        <feature>concurrent-1.0</feature>
        <feature>appClientSupport-1.0</feature>
        <feature>ejbRemote-3.2</feature>
        <feature>jaxb-2.2</feature>
        <feature>mdb-3.2</feature>
        <feature>jacc-1.5</feature>
        <feature>batch-1.0</feature>
        <feature>ejb-3.2</feature>
        <feature>json-1.0</feature>
        <feature>jaspic-1.1</feature>
        <feature>distributedMap-1.0</feature>
        <feature>websocket-1.1</feature>
        <feature>wasJmsSecurity-1.0</feature>
        <feature>wasJmsClient-2.0</feature>
        <!-- was 2.1 but we need openjpa -->
        <feature>jpa-2.0</feature>
        <!-- end javaee-7.0 -->
        <feature>adminCenter-1.0</feature>
    </featureManager>



    <basicRegistry id="basic" realm="BasicRealm"> 
        <user name="development" password="development" /> 
    </basicRegistry>
    <!-- Define a keystore for the HTTPS port -->
    <keyStore id="defaultKeyStore" password="development"/>
    <administrator-role>
        <user>development</user>
    </administrator-role>    
    
    <!-- To access this server from a remote client add a host attribute to the following element, e.g. host="*" -->
    <httpEndpoint id="defaultHttpEndpoint" host="*" httpPort="9080" httpsPort="9443" />
                  
    <applicationManager autoExpand="true"/>


    <!-- Allows remote file access for config changes -->
    <remoteFileAccess>
      <writeDir>${server.config.dir}</writeDir>
    </remoteFileAccess>

</server>

EOF

bin/installUtility install jpa-2.0 --acceptLicense
chown -R liberty:liberty /opt/liberty/
#!/bin/bash -e

echo "Installing tomcat"
mkdir -p /opt/apache-tomcat/conf
cp -R /tmp/apache-tomcat*/* /opt/apache-tomcat
rm -rf /opt/apache-tomcat/webapps/*

cat <<-'EOF' > /opt/apache-tomcat/bin/setenv.sh
JAVA_OPTS=-Djava.security.egd=file:/dev/./urandom
EOF

cat <<-'EOF' > /opt/apache-tomcat/conf/logging.properties
	handlers = java.util.logging.ConsoleHandler
	.handlers = java.util.logging.ConsoleHandler

	java.util.logging.ConsoleHandler.level = INFO
	java.util.logging.ConsoleHandler.formatter=java.util.logging.SimpleFormatter
	java.util.logging.SimpleFormatter.format=[tomcat8][%4$s][%3$s] %5$s%6$s%n
EOF

cat <<'EOF' > /opt/apache-tomcat/conf/server.xml
<?xml version='1.0' encoding='utf-8'?>
<Server port="8005" shutdown="SHUTDOWN">
  <Listener className="org.apache.catalina.startup.VersionLoggerListener" />
  <!--
  <Listener className="org.apache.catalina.core.AprLifecycleListener" SSLEngine="on" />
  -->
  <Listener className="org.apache.catalina.core.JreMemoryLeakPreventionListener" />
  <Listener className="org.apache.catalina.mbeans.GlobalResourcesLifecycleListener" />
  <Listener className="org.apache.catalina.core.ThreadLocalLeakPreventionListener" />

  <Service name="Catalina">
    <Connector port="8443" 
        protocol="org.apache.coyote.http11.Http11NioProtocol"
        maxThreads="150" 
        SSLEnabled="true" 
        scheme="https" 
        secure="true"
        clientAuth="false" 
        sslProtocol="TLS"
        keystoreFile="/opt/apache-tomcat/conf/keystore" 
        keystorePass="changeit"
    />

    <Connector port="8084" 
        URIEncoding="utf-8" 
        connectionTimeout="20000"
        protocol="HTTP/1.1"
    />    

    <Engine name="Catalina" defaultHost="localhost">
      <Host name="localhost"  appBase="webapps" unpackWARs="true" autoDeploy="true" >
        <Valve className="org.apache.catalina.valves.RemoteIpValve"
            remoteIpHeader="x-forwarded-for"
            proxiesHeader="x-forwarded-by"
            protocolHeader="x-forwarded-proto" />
      </Host>
    </Engine>

  </Service>
</Server>
EOF



keytool \
    -genkey \
    -alias tomcat \
    -dname "CN=example.com, OU=example, O=example.com, L=Italy, S=Unknown, C=IT" \
    -keyalg RSA \
    -keystore /opt/apache-tomcat/conf/keystore \
    -storepass changeit  \
    -keypass changeit \
    -validity 9999

groupadd -r tomcat 
useradd -r -m -g tomcat tomcat
chown -R tomcat:tomcat /opt/apache-tomcat


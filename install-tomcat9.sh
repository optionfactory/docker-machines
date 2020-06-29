#!/bin/bash -e

echo "Installing tomcat"
mkdir -p /opt/apache-tomcat/conf
cp -R /tmp/apache-tomcat*/* /opt/apache-tomcat
cp /tmp/tomcat9-logging-error-report-valve-1.0.jar /opt/apache-tomcat/lib/
rm -rf /opt/apache-tomcat/webapps/*

cat <<-'EOF' > /opt/apache-tomcat/bin/setenv.sh
JAVA_OPTS="$JAVA_OPTS -Djava.security.egd=file:/dev/./urandom"
EOF

cat <<-'EOF' > /opt/apache-tomcat/conf/logging.properties
	handlers = java.util.logging.ConsoleHandler
	.handlers = java.util.logging.ConsoleHandler

	java.util.logging.ConsoleHandler.level = INFO
	java.util.logging.ConsoleHandler.formatter=java.util.logging.SimpleFormatter
	java.util.logging.SimpleFormatter.format=[tomcat9][%4$s][%3$s] %5$s%6$s%n
EOF

cat <<'EOF' > /opt/apache-tomcat/conf/server.xml
<?xml version='1.0' encoding='utf-8'?>
<Server port="8005" shutdown="SHUTDOWN">
  <Listener className="org.apache.catalina.startup.VersionLoggerListener" />
  <Listener className="org.apache.catalina.core.JreMemoryLeakPreventionListener" />
  <Listener className="org.apache.catalina.mbeans.GlobalResourcesLifecycleListener" />
  <Listener className="org.apache.catalina.core.ThreadLocalLeakPreventionListener" />
  <Service name="Catalina">
    <Connector Server=" " URIEncoding="utf-8" port="8084" connectionTimeout="20000" protocol="HTTP/1.1"/>
    <Engine name="Catalina" defaultHost="localhost">
      <Host name="localhost" appBase="webapps" unpackWARs="true" autoDeploy="true" errorReportValveClass="net.optionfactory.tomcat9.lerv.LoggingErrorReportValve">
        <Valve className="org.apache.catalina.valves.RemoteIpValve" protocolHeader="X-Forwarded-Proto" />
      </Host>
    </Engine>
  </Service>
</Server>
EOF
cat <<'EOF' > /opt/apache-tomcat/conf/context.xml
<?xml version="1.0" encoding="UTF-8"?>
<Context>
    <WatchedResource>WEB-INF/web.xml</WatchedResource>
    <WatchedResource>WEB-INF/tomcat-web.xml</WatchedResource>
    <WatchedResource>${catalina.base}/conf/web.xml</WatchedResource>
    <CookieProcessor sameSiteCookies="strict" />
</Context>
EOF

groupadd --system --gid 20000 docker-machines
useradd --system --create-home --gid docker-machines --uid 20000 tomcat
chown -R tomcat:docker-machines /opt/apache-tomcat

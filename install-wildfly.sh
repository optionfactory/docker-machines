#!/bin/bash -e

echo "Installing wildfly"
groupadd -r wildfly 
useradd -r -m -g wildfly wildfly
mkdir -p /opt/wildfly
cp -R /tmp/wildfly-*/* /opt/wildfly

echo "Removing unused features"
rm -rf /opt/wildfly/standalone/configuration/*
rm -rf /opt/wildfly/standalone/log
rm -rf /opt/wildfly/appclient
rm -rf /opt/wildfly/domain
rm -rf /opt/wildfly/docs
rm -rf /opt/wildfly/welcome-content

echo "configuring"

keytool \
    -genkey \
    -alias wildfly \
    -dname "CN=example.com, OU=example, O=example.com, L=Italy, S=Unknown, C=IT" \
    -keyalg RSA \
    -keystore /opt/wildfly/standalone/configuration/keystore.jks \
    -storepass changeit  \
    -keypass changeit \
    -validity 9999


cat <<'EOF' > /opt/wildfly/standalone/configuration/application-roles.properties
EOF
cat <<'EOF' > /opt/wildfly/standalone/configuration/application-users.properties
EOF
cat <<-'EOF' > /opt/wildfly/standalone/configuration/logging.properties
	# Additional loggers to configure (the root logger is always configured)
	loggers=jacorb,sun.rmi,org.jboss.as.config,jacorb.config,org.apache.tomcat.util.modeler,com.arjuna

	logger.level=INFO
	logger.handlers=CONSOLE

	logger.jacorb.level=WARN
	logger.jacorb.useParentHandlers=true

	logger.sun.rmi.level=WARN
	logger.sun.rmi.useParentHandlers=true

	logger.org.jboss.as.config.level=DEBUG
	logger.org.jboss.as.config.useParentHandlers=true

	logger.jacorb.config.level=ERROR
	logger.jacorb.config.useParentHandlers=true

	logger.org.apache.tomcat.util.modeler.level=WARN
	logger.org.apache.tomcat.util.modeler.useParentHandlers=true

	logger.com.arjuna.level=WARN
	logger.com.arjuna.useParentHandlers=true

	handler.CONSOLE=org.jboss.logmanager.handlers.ConsoleHandler
	handler.CONSOLE.level=INFO
	handler.CONSOLE.formatter=PATTERN
	handler.CONSOLE.properties=autoFlush,target,enabled
	handler.CONSOLE.autoFlush=true
	handler.CONSOLE.target=SYSTEM_OUT
	handler.CONSOLE.enabled=true

	formatter.PATTERN=org.jboss.logmanager.formatters.PatternFormatter
	formatter.PATTERN.properties=pattern
	formatter.PATTERN.pattern=[%z{utc}%d{dd-MM-yyyy'T'HH:mm:ss,SSS}Z][wildfly][%p][%c](%t) %s%E%n
EOF
cat <<-'EOF' > /opt/wildfly/standalone/configuration/mgmt-groups.properties
	#
	# Properties declaration of users groups for the realm 'ManagementRealm'.
	#
	# This is used for domain management, users groups membership information is used to assign the user
	# specific management roles.
	#
	# Users can be added to this properties file at any time, updates after the server has started
	# will be automatically detected.
	#
	# The format of this file is as follows: -
	# username=role1,role2,role3
	#
	# A utility script is provided which can be executed from the bin folder to add the users: -
	# - Linux
	#  bin/add-user.sh
	#
	# - Windows
	#  bin\add-user.bat
	#
	# The following illustrates how an admin user could be defined.
	#
	#admin=PowerUser,BillingAdmin,
EOF
cat <<-'EOF' > /opt/wildfly/standalone/configuration/mgmt-users.properties
	#
	# Properties declaration of users for the realm 'ManagementRealm' which is the default realm
	# for new installations. Further authentication mechanism can be configured
	# as part of the <management /> in standalone.xml.
	#
	# Users can be added to this properties file at any time, updates after the server has started
	# will be automatically detected.
	#
	# By default the properties realm expects the entries to be in the format: -
	# username=HEX( MD5( username ':' realm ':' password))
	#
	# A utility script is provided which can be executed from the bin folder to add the users: -
	# - Linux
	#  bin/add-user.sh
	#
	# - Windows
	#  bin\add-user.bat
	#
	#$REALM_NAME=ManagementRealm$ This line is used by the add-user utility to identify the realm name already used in this file.
	#
	# On start-up the server will also automatically add a user $local - this user is specifically
	# for local tools running against this AS installation.
	#
	# The following illustrates how an admin user could be defined, this
	# is for illustration only and does not correspond to a usable password.
	#
	#admin=2a0923285184943425d1f53ddd58ec7a
EOF
cat <<'EOF' > /opt/wildfly/standalone/configuration/standalone.xml
<?xml version='1.0' encoding='UTF-8'?>

<server xmlns="urn:jboss:domain:2.2">
    <extensions>
        <extension module="org.jboss.as.connector"/>
        <extension module="org.jboss.as.deployment-scanner"/>
        <extension module="org.jboss.as.ee"/>
        <extension module="org.jboss.as.jmx"/>
        <extension module="org.jboss.as.logging"/>
        <extension module="org.jboss.as.naming"/>
        <extension module="org.jboss.as.remoting"/>
        <extension module="org.jboss.as.security"/>
        <extension module="org.jboss.as.transactions"/>
        <extension module="org.jboss.as.weld"/>
        <extension module="org.wildfly.extension.io"/>
        <extension module="org.wildfly.extension.undertow"/>
    </extensions>
    <management>
        <security-realms>
            <security-realm name="SSL">
              <server-identities>
                <ssl protocol="TLS">
                  <keystore path="keystore.jks" relative-to="jboss.server.config.dir" keystore-password="changeit" alias="wildfly"/>
                </ssl>
              </server-identities>
              <authentication>
                <truststore path="keystore.jks" relative-to="jboss.server.config.dir" keystore-password="changeit"/>
              </authentication>
            </security-realm>
            <security-realm name="ManagementRealm">
                <authentication>
                    <local default-user="$local" skip-group-loading="true"/>
                    <properties path="mgmt-users.properties" relative-to="jboss.server.config.dir"/>
                </authentication>
                <authorization map-groups-to-roles="false">
                    <properties path="mgmt-groups.properties" relative-to="jboss.server.config.dir"/>
                </authorization>
            </security-realm>
            <security-realm name="ApplicationRealm">
                <authentication>
                    <local default-user="$local" allowed-users="*" skip-group-loading="true"/>
                    <properties path="application-users.properties" relative-to="jboss.server.config.dir"/>
                </authentication>
                <authorization>
                    <properties path="application-roles.properties" relative-to="jboss.server.config.dir"/>
                </authorization>
            </security-realm>
        </security-realms>
        <management-interfaces>
            <http-interface security-realm="ManagementRealm" http-upgrade-enabled="true">
                <socket-binding http="management-http"/>
            </http-interface>
        </management-interfaces>
        <access-control provider="simple">
            <role-mapping>
                <role name="SuperUser">
                    <include>
                        <user name="$local"/>
                    </include>
                </role>
            </role-mapping>
        </access-control>
    </management>
    <profile>
        <subsystem xmlns="urn:jboss:domain:logging:2.0">
            <console-handler name="CONSOLE">
                <level name="INFO"/>
                <formatter><named-formatter name="PATTERN"/></formatter>
            </console-handler>
            <logger category="com.arjuna"><level name="WARN"/></logger>
            <logger category="org.apache.tomcat.util.modeler"><level name="WARN"/></logger>
            <logger category="org.jboss.as.config"><level name="DEBUG"/></logger>
            <logger category="sun.rmi"><level name="WARN"/></logger>
            <logger category="jacorb"><level name="WARN"/></logger>
            <logger category="jacorb.config"><level name="ERROR"/></logger>
            <root-logger>
                <level name="INFO"/>
                <handlers><handler name="CONSOLE"/></handlers>
            </root-logger>
            <formatter name="PATTERN"><pattern-formatter pattern="[%z{utc}%d{dd-MM-yyyy'T'HH:mm:ss,SSS}Z][wildfly][%p][%c](%t) %s%E%n"/></formatter>
        </subsystem>
        <subsystem xmlns="urn:jboss:domain:deployment-scanner:2.0">
            <deployment-scanner path="deployments" relative-to="jboss.server.base.dir" scan-interval="5000" runtime-failure-causes-rollback="${jboss.deployment.scanner.rollback.on.failure:false}"/>
        </subsystem>
        <subsystem xmlns="urn:jboss:domain:ee:2.0">
            <spec-descriptor-property-replacement>false</spec-descriptor-property-replacement>
            <concurrent>
                <context-services>
                    <context-service name="default" jndi-name="java:jboss/ee/concurrency/context/default" use-transaction-setup-provider="true"/>
                </context-services>
                <managed-executor-services>
                    <managed-executor-service name="default" jndi-name="java:jboss/ee/concurrency/executor/default" context-service="default" hung-task-threshold="60000" core-threads="5" max-threads="25" keepalive-time="5000"/>
                </managed-executor-services>
                <managed-scheduled-executor-services>
                    <managed-scheduled-executor-service name="default" jndi-name="java:jboss/ee/concurrency/scheduler/default" context-service="default" hung-task-threshold="60000" core-threads="2" keepalive-time="3000"/>
                </managed-scheduled-executor-services>
                <managed-thread-factories>
                    <managed-thread-factory name="default" jndi-name="java:jboss/ee/concurrency/factory/default" context-service="default"/>
                </managed-thread-factories>
            </concurrent>
        </subsystem>
        <subsystem xmlns="urn:jboss:domain:io:1.1">
            <worker name="default"/>
            <buffer-pool name="default"/>
        </subsystem>
        <subsystem xmlns="urn:jboss:domain:jmx:1.3">
            <expose-resolved-model/>
            <expose-expression-model/>
            <remoting-connector/>
        </subsystem>
        <subsystem xmlns="urn:jboss:domain:naming:2.0">
            <remote-naming/>
        </subsystem>
        <subsystem xmlns="urn:jboss:domain:remoting:2.0">
            <endpoint worker="default"/>
            <http-connector name="http-remoting-connector" connector-ref="default" security-realm="ApplicationRealm"/>
        </subsystem>
        <subsystem xmlns="urn:jboss:domain:resource-adapters:2.0"/>
        <subsystem xmlns="urn:jboss:domain:security:1.2">
            <security-domains>
                <security-domain name="other" cache-type="default">
                    <authentication>
                        <login-module code="Remoting" flag="optional">
                            <module-option name="password-stacking" value="useFirstPass"/>
                        </login-module>
                        <login-module code="RealmDirect" flag="required">
                            <module-option name="password-stacking" value="useFirstPass"/>
                        </login-module>
                    </authentication>
                </security-domain>
                <security-domain name="jboss-web-policy" cache-type="default">
                    <authorization>
                        <policy-module code="Delegating" flag="required"/>
                    </authorization>
                </security-domain>
            </security-domains>
        </subsystem>
        <subsystem xmlns="urn:jboss:domain:transactions:2.0">
            <core-environment>
                <process-id>
                    <uuid/>
                </process-id>
            </core-environment>
            <recovery-environment socket-binding="txn-recovery-environment" status-socket-binding="txn-status-manager"/>
        </subsystem>
        <subsystem xmlns="urn:jboss:domain:undertow:1.2">
            <buffer-cache name="default"/>
            <server name="default-server">
                <https-listener name="default" socket-binding="https" security-realm="SSL" tcp-keep-alive="true" no-request-timeout="3600000" read-timeout="3600000"/>
                <host name="default-host" alias="localhost">
                    <location name="/" handler="welcome-content"/>
                    <filter-ref name="server-header"/>
                    <filter-ref name="x-powered-by-header"/>
                </host>
            </server>
            <servlet-container name="default">
                <jsp-config/>
                <websockets/>
            </servlet-container>
            <handlers>
                <file name="welcome-content" path="${jboss.home.dir}/welcome-content"/>
            </handlers>
            <filters>
                <response-header name="server-header" header-name="Server" header-value="WildFly/8"/>
                <response-header name="x-powered-by-header" header-name="X-Powered-By" header-value="Undertow/1"/>
            </filters>
        </subsystem>
        <subsystem xmlns="urn:jboss:domain:weld:2.0"/>
    </profile>
    <interfaces>
        <interface name="management">
            <inet-address value="${jboss.bind.address.management:127.0.0.1}"/>
        </interface>
        <interface name="public">
            <inet-address value="${jboss.bind.address:127.0.0.1}"/>
        </interface>
    </interfaces>
    <socket-binding-group name="standard-sockets" default-interface="public" port-offset="${jboss.socket.binding.port-offset:0}">
        <socket-binding name="management-http" interface="management" port="${jboss.management.http.port:9990}"/>
        <socket-binding name="https" port="${jboss.https.port:8443}"/>
        <socket-binding name="txn-recovery-environment" port="4712"/>
        <socket-binding name="txn-status-manager" port="4713"/>
    </socket-binding-group>
</server>
EOF


chown -R wildfly:wildfly /opt/wildfly

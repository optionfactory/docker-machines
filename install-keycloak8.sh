#!/bin/bash -e

echo "Installing Keycloak 8"
mkdir -p /opt/keycloak
cp -R /tmp/keycloak*/* /opt/keycloak


mkdir -p /opt/keycloak/modules/org/postgresql/main/
cp /tmp/postgresql-42.2.8.jar /opt/keycloak/modules/org/postgresql/main/
#cp driver
cat <<-'EOF' > /opt/keycloak/modules/org/postgresql/main/module.xml
<?xml version="1.0" ?>
<module xmlns="urn:jboss:module:1.3" name="org.postgresql">
    <resources>
        <resource-root path="postgresql-42.2.8.jar"/>
    </resources>
    <dependencies>
        <module name="javax.api"/>
        <module name="javax.transaction.api"/>
    </dependencies>
</module>
EOF

cat <<-'EOF' > /opt/keycloak/standalone/configuration/standalone.xml
<?xml version='1.0' encoding='UTF-8'?>

<server xmlns="urn:jboss:domain:10.0">
    <extensions>
        <extension module="org.jboss.as.clustering.infinispan"/>
        <extension module="org.jboss.as.connector"/>
        <extension module="org.jboss.as.deployment-scanner"/>
        <extension module="org.jboss.as.ee"/>
        <extension module="org.jboss.as.ejb3"/>
        <extension module="org.jboss.as.jaxrs"/>
        <extension module="org.jboss.as.jpa"/>
        <extension module="org.jboss.as.logging"/>
        <extension module="org.jboss.as.mail"/>
        <extension module="org.jboss.as.naming"/>
        <extension module="org.jboss.as.remoting"/>
        <extension module="org.jboss.as.security"/>
        <extension module="org.jboss.as.transactions"/>
        <extension module="org.jboss.as.weld"/>
        <extension module="org.keycloak.keycloak-server-subsystem"/>
        <extension module="org.wildfly.extension.bean-validation"/>
        <extension module="org.wildfly.extension.core-management"/>
        <extension module="org.wildfly.extension.io"/>
        <extension module="org.wildfly.extension.request-controller"/>
        <extension module="org.wildfly.extension.security.manager"/>
        <extension module="org.wildfly.extension.undertow"/>
    </extensions>
    <management>
        <security-realms>
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
                <server-identities>
                    <ssl>
                        <keystore path="application.keystore" relative-to="jboss.server.config.dir" keystore-password="password" alias="server" key-password="password" generate-self-signed-certificate-host="localhost"/>
                    </ssl>
                </server-identities>
                <authentication>
                    <local default-user="$local" allowed-users="*" skip-group-loading="true"/>
                    <properties path="application-users.properties" relative-to="jboss.server.config.dir"/>
                </authentication>
                <authorization>
                    <properties path="application-roles.properties" relative-to="jboss.server.config.dir"/>
                </authorization>
            </security-realm>
        </security-realms>
        <audit-log>
            <formatters>
                <json-formatter name="json-formatter"/>
            </formatters>
            <handlers>
                <file-handler name="file" formatter="json-formatter" path="audit-log.log" relative-to="jboss.server.data.dir"/>
            </handlers>
            <logger log-boot="true" log-read-only="false" enabled="false">
                <handlers>
                    <handler name="file"/>
                </handlers>
            </logger>
        </audit-log>
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
        <subsystem xmlns="urn:jboss:domain:logging:8.0">
            <console-handler name="CONSOLE">
                <level name="INFO"/>
                <formatter>
                    <named-formatter name="PATTERN"/>
                </formatter>
            </console-handler>
            <logger category="com.arjuna">
                <level name="WARN"/>
            </logger>
            <logger category="io.jaegertracing.Configuration">
                <level name="WARN"/>
            </logger>
            <logger category="org.jboss.as.config">
                <level name="DEBUG"/>
            </logger>
            <logger category="sun.rmi">
                <level name="WARN"/>
            </logger>
            <root-logger>
                <level name="INFO"/>
                <handlers>
                    <handler name="CONSOLE"/>
                </handlers>
            </root-logger>
            <formatter name="PATTERN">
                <pattern-formatter pattern="%d{yyyy-MM-dd HH:mm:ss,SSS} %-5p [%c] (%t) %s%e%n"/>
            </formatter>
        </subsystem>
        <subsystem xmlns="urn:jboss:domain:bean-validation:1.0"/>
        <subsystem xmlns="urn:jboss:domain:core-management:1.0"/>
        <subsystem xmlns="urn:jboss:domain:datasources:5.0">
            <datasources>
                <datasource jndi-name="java:jboss/datasources/KeycloakDS" pool-name="KeycloakDS" enabled="true" use-java-context="true" statistics-enabled="${wildfly.datasources.statistics-enabled:${wildfly.statistics-enabled:false}}">
                    <connection-url>jdbc:postgresql://${postgres.host:172.17.0.1}/keycloak</connection-url>
                    <driver>postgresql</driver>
                    <security>
                        <user-name>${postgres.username:postgres}</user-name>
                        <password>${postgres.password:""}</password>
                    </security>
                </datasource>
                <drivers>
                    <driver name="postgresql" module="org.postgresql">
                        <xa-datasource-class>org.postgresql.xa.PGXADataSource</xa-datasource-class>
                    </driver>
                </drivers>
            </datasources>
        </subsystem>
        <subsystem xmlns="urn:jboss:domain:deployment-scanner:2.0">
            <deployment-scanner path="deployments" relative-to="jboss.server.base.dir" scan-interval="5000" runtime-failure-causes-rollback="${jboss.deployment.scanner.rollback.on.failure:false}"/>
        </subsystem>
        <subsystem xmlns="urn:jboss:domain:ee:4.0">
            <spec-descriptor-property-replacement>false</spec-descriptor-property-replacement>
            <concurrent>
                <context-services>
                    <context-service name="default" jndi-name="java:jboss/ee/concurrency/context/default" use-transaction-setup-provider="true"/>
                </context-services>
                <managed-thread-factories>
                    <managed-thread-factory name="default" jndi-name="java:jboss/ee/concurrency/factory/default" context-service="default"/>
                </managed-thread-factories>
                <managed-executor-services>
                    <managed-executor-service name="default" jndi-name="java:jboss/ee/concurrency/executor/default" context-service="default" hung-task-threshold="60000" keepalive-time="5000"/>
                </managed-executor-services>
                <managed-scheduled-executor-services>
                    <managed-scheduled-executor-service name="default" jndi-name="java:jboss/ee/concurrency/scheduler/default" context-service="default" hung-task-threshold="60000" keepalive-time="3000"/>
                </managed-scheduled-executor-services>
            </concurrent>
            <default-bindings
                context-service="java:jboss/ee/concurrency/context/default"
                datasource="java:jboss/datasources/KeycloakDS"
                managed-executor-service="java:jboss/ee/concurrency/executor/default"
                managed-scheduled-executor-service="java:jboss/ee/concurrency/scheduler/default"
                managed-thread-factory="java:jboss/ee/concurrency/factory/default"/>
        </subsystem>
        <subsystem xmlns="urn:jboss:domain:io:3.0">
            <worker name="default"/>
            <buffer-pool name="default"/>
        </subsystem>
        <subsystem xmlns="urn:jboss:domain:infinispan:9.0">
            <cache-container name="keycloak">
                <local-cache name="realms">
                    <object-memory size="10000"/>
                </local-cache>
                <local-cache name="users">
                    <object-memory size="10000"/>
                </local-cache>
                <local-cache name="sessions"/>
                <local-cache name="authenticationSessions"/>
                <local-cache name="offlineSessions"/>
                <local-cache name="clientSessions"/>
                <local-cache name="offlineClientSessions"/>
                <local-cache name="loginFailures"/>
                <local-cache name="work"/>
                <local-cache name="authorization">
                    <object-memory size="10000"/>
                </local-cache>
                <local-cache name="keys">
                    <object-memory size="1000"/>
                    <expiration max-idle="3600000"/>
                </local-cache>
                <local-cache name="actionTokens">
                    <object-memory size="-1"/>
                    <expiration max-idle="-1" interval="300000"/>
                </local-cache>
            </cache-container>
            <cache-container name="server" default-cache="default" module="org.wildfly.clustering.server">
                <local-cache name="default">
                    <transaction mode="BATCH"/>
                </local-cache>
            </cache-container>
            <cache-container name="web" default-cache="passivation" module="org.wildfly.clustering.web.infinispan">
                <local-cache name="passivation">
                    <locking isolation="REPEATABLE_READ"/>
                    <transaction mode="BATCH"/>
                    <file-store passivation="true" purge="false"/>
                </local-cache>
                <local-cache name="sso">
                    <locking isolation="REPEATABLE_READ"/>
                    <transaction mode="BATCH"/>
                </local-cache>
                <local-cache name="routing"/>
            </cache-container>
            <cache-container name="ejb" aliases="sfsb" default-cache="passivation" module="org.wildfly.clustering.ejb.infinispan">
                <local-cache name="passivation">
                    <locking isolation="REPEATABLE_READ"/>
                    <transaction mode="BATCH"/>
                    <file-store passivation="true" purge="false"/>
                </local-cache>
            </cache-container>
            <cache-container name="hibernate" module="org.infinispan.hibernate-cache">
                <local-cache name="entity">
                    <object-memory size="10000"/>
                    <expiration max-idle="100000"/>
                </local-cache>
                <local-cache name="local-query">
                    <object-memory size="10000"/>
                    <expiration max-idle="100000"/>
                </local-cache>
                <local-cache name="timestamps"/>
            </cache-container>
        </subsystem>
        <subsystem xmlns="urn:jboss:domain:jaxrs:1.0"/>
        <subsystem xmlns="urn:jboss:domain:jca:5.0">
            <archive-validation enabled="true" fail-on-error="true" fail-on-warn="false"/>
            <bean-validation enabled="true"/>
            <default-workmanager>
                <short-running-threads>
                    <core-threads count="50"/>
                    <queue-length count="50"/>
                    <max-threads count="50"/>
                    <keepalive-time time="10" unit="seconds"/>
                </short-running-threads>
                <long-running-threads>
                    <core-threads count="50"/>
                    <queue-length count="50"/>
                    <max-threads count="50"/>
                    <keepalive-time time="10" unit="seconds"/>
                </long-running-threads>
            </default-workmanager>
            <cached-connection-manager/>
        </subsystem>
        <subsystem xmlns="urn:jboss:domain:jpa:1.1">
            <jpa default-datasource="" default-extended-persistence-inheritance="DEEP"/>
        </subsystem>
        <subsystem xmlns="urn:jboss:domain:mail:3.0">
            <mail-session name="default" jndi-name="java:jboss/mail/Default">
                <smtp-server outbound-socket-binding-ref="mail-smtp"/>
            </mail-session>
        </subsystem>
        <subsystem xmlns="urn:jboss:domain:naming:2.0">
            <remote-naming/>
        </subsystem>
        <subsystem xmlns="urn:jboss:domain:remoting:4.0">
            <http-connector name="http-remoting-connector" connector-ref="default" security-realm="ApplicationRealm"/>
        </subsystem>
        <subsystem xmlns="urn:jboss:domain:request-controller:1.0"/>
        <subsystem xmlns="urn:jboss:domain:security-manager:1.0">
            <deployment-permissions>
                <maximum-set>
                    <permission class="java.security.AllPermission"/>
                </maximum-set>
            </deployment-permissions>
        </subsystem>
        <subsystem xmlns="urn:jboss:domain:security:2.0">
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
                <security-domain name="jaspitest" cache-type="default">
                    <authentication-jaspi>
                        <login-module-stack name="dummy">
                            <login-module code="Dummy" flag="optional"/>
                        </login-module-stack>
                        <auth-module code="Dummy"/>
                    </authentication-jaspi>
                </security-domain>
                <security-domain name="jboss-ejb-policy" cache-type="default">
                    <authorization>
                        <policy-module code="Delegating" flag="required"/>
                    </authorization>
                </security-domain>
            </security-domains>
        </subsystem>
        <subsystem xmlns="urn:jboss:domain:transactions:5.0">
            <core-environment node-identifier="${jboss.tx.node.id:1}">
                <process-id>
                    <uuid/>
                </process-id>
            </core-environment>
            <recovery-environment socket-binding="txn-recovery-environment" status-socket-binding="txn-status-manager"/>
            <coordinator-environment statistics-enabled="${wildfly.transactions.statistics-enabled:${wildfly.statistics-enabled:false}}"/>
            <object-store path="tx-object-store" relative-to="jboss.server.data.dir"/>
        </subsystem>
        <subsystem xmlns="urn:jboss:domain:weld:4.0"/>
        <subsystem xmlns="urn:jboss:domain:undertow:10.0" default-server="default-server" default-virtual-host="default-host" default-servlet-container="default" default-security-domain="other" statistics-enabled="${wildfly.undertow.statistics-enabled:${wildfly.statistics-enabled:false}}">
            <buffer-cache name="default"/>
            <server name="default-server">
				<http-listener name="default" socket-binding="http" />
                <host name="default-host" alias="localhost">
                    <location name="/" handler="welcome-content"/>
                    <http-invoker security-realm="ApplicationRealm"/>
                </host>
            </server>
            <servlet-container name="default">
                <jsp-config/>
                <websockets/>
            </servlet-container>
            <handlers>
                <file name="welcome-content" path="${jboss.home.dir}/welcome-content"/>
            </handlers>
        </subsystem>
        <subsystem xmlns="urn:jboss:domain:keycloak-server:1.1">
            <web-context>auth</web-context>
            <providers>
                <provider>classpath:${jboss.home.dir}/providers/*</provider>
            </providers>
            <master-realm-name>master</master-realm-name>
            <scheduled-task-interval>900</scheduled-task-interval>
            <theme>
                <staticMaxAge>2592000</staticMaxAge>
                <cacheThemes>true</cacheThemes>
                <cacheTemplates>true</cacheTemplates>
                <dir>${jboss.home.dir}/themes</dir>
            </theme>
            <spi name="eventsStore">
                <provider name="jpa" enabled="true">
                    <properties>
                        <property name="exclude-events" value="[&quot;REFRESH_TOKEN&quot;]"/>
                    </properties>
                </provider>
            </spi>
            <spi name="userCache">
                <provider name="default" enabled="true"/>
            </spi>
            <spi name="userSessionPersister">
                <default-provider>jpa</default-provider>
            </spi>
            <spi name="timer">
                <default-provider>basic</default-provider>
            </spi>
            <spi name="connectionsHttpClient">
                <provider name="default" enabled="true"/>
            </spi>
            <spi name="connectionsJpa">
                <provider name="default" enabled="true">
                    <properties>
                        <property name="dataSource" value="java:jboss/datasources/KeycloakDS"/>
                        <property name="initializeEmpty" value="true"/>
                        <property name="migrationStrategy" value="update"/>
                        <property name="migrationExport" value="${jboss.home.dir}/keycloak-database-update.sql"/>
                    </properties>
                </provider>
            </spi>
            <spi name="realmCache">
                <provider name="default" enabled="true"/>
            </spi>
            <spi name="connectionsInfinispan">
                <default-provider>default</default-provider>
                <provider name="default" enabled="true">
                    <properties>
                        <property name="cacheContainer" value="java:jboss/infinispan/container/keycloak"/>
                    </properties>
                </provider>
            </spi>
            <spi name="jta-lookup">
                <default-provider>${keycloak.jta.lookup.provider:jboss}</default-provider>
                <provider name="jboss" enabled="true"/>
            </spi>
            <spi name="publicKeyStorage">
                <provider name="infinispan" enabled="true">
                    <properties>
                        <property name="minTimeBetweenRequests" value="10"/>
                    </properties>
                </provider>
            </spi>
            <spi name="x509cert-lookup">
                <default-provider>${keycloak.x509cert.lookup.provider:default}</default-provider>
                <provider name="default" enabled="true"/>
            </spi>
            <spi name="hostname">
                <default-provider>default</default-provider>
                <provider name="default" enabled="true">
                    <properties>
                        <property name="frontendUrl" value="${keycloak.frontendUrl:}"/>
                        <property name="forceBackendUrlToFrontendUrl" value="false"/>
                    </properties>
                </provider>
            </spi>
        </subsystem>
    </profile>
    <interfaces>
        <interface name="public">
            <inet-address value="0.0.0.0"/>
        </interface>
    </interfaces>
    <socket-binding-group name="standard-sockets" default-interface="public" port-offset="${jboss.socket.binding.port-offset:0}">
		<socket-binding name="http" port="8080"/>
        <socket-binding name="txn-recovery-environment" port="4712"/>
        <socket-binding name="txn-status-manager" port="4713"/>
        <outbound-socket-binding name="mail-smtp">
            <remote-destination host="localhost" port="25"/>
        </outbound-socket-binding>
    </socket-binding-group>
</server>
EOF


cat <<-'EOF' > /opt/keycloak/standalone/configuration/logging.properties
logger.level=${jboss.boot.server.log.level:INFO}
logger.handlers=CONSOLE
handler.CONSOLE=org.jboss.logmanager.handlers.ConsoleHandler
handler.CONSOLE.properties=autoFlush,target
handler.CONSOLE.level=${jboss.boot.server.log.console.level:INFO}
handler.CONSOLE.autoFlush=true
handler.CONSOLE.formatter=PATTERN
handler.CONSOLE.target=SYSTEM_OUT
formatter.PATTERN=org.jboss.logmanager.formatters.PatternFormatter
formatter.PATTERN.properties=pattern
formatter.PATTERN.pattern=%d{yyyy-MM-dd HH\:mm\:ss,SSS} %-5p [%c] (%t) %s%e%n
EOF


rm -rf /opt/keycloak/domain/
rm -rf /opt/keycloak/docs/

groupadd -r keycloak
useradd -r -m -g keycloak keycloak
chown -R keycloak:keycloak /opt/keycloak

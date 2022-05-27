#!/bin/bash -e

echo "Installing Keycloak"
mkdir -p /opt/keycloak
cp -R /tmp/keycloak*/* /opt/keycloak


mkdir -p /opt/keycloak/modules/org/postgresql/main/
cp /tmp/postgresql-42.3.1.jar /opt/keycloak/modules/org/postgresql/main/
#cp driver
cat <<-'EOF' > /opt/keycloak/modules/org/postgresql/main/module.xml
<?xml version="1.0" ?>
<module xmlns="urn:jboss:module:1.3" name="org.postgresql">
    <resources>
        <resource-root path="postgresql-42.3.1.jar"/>
    </resources>
    <dependencies>
        <module name="javax.api"/>
        <module name="javax.transaction.api"/>
    </dependencies>
</module>
EOF

cat <<-'EOF' > /opt/keycloak/standalone/configuration/standalone.xml
<?xml version='1.0' encoding='UTF-8'?>

<server xmlns="urn:jboss:domain:18.0">
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
        <extension module="org.jboss.as.transactions"/>
        <extension module="org.jboss.as.weld"/>
        <extension module="org.keycloak.keycloak-server-subsystem"/>
        <extension module="org.wildfly.extension.bean-validation"/>
        <extension module="org.wildfly.extension.core-management"/>
        <extension module="org.wildfly.extension.elytron"/>
        <extension module="org.wildfly.extension.io"/>
        <extension module="org.wildfly.extension.request-controller"/>
        <extension module="org.wildfly.extension.security.manager"/>
        <extension module="org.wildfly.extension.undertow"/>
    </extensions>
    <management>
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
        <subsystem xmlns="urn:jboss:domain:datasources:6.0">
            <datasources>
                <datasource jndi-name="java:jboss/datasources/KeycloakDS" pool-name="KeycloakDS" enabled="true" use-java-context="true" statistics-enabled="${wildfly.datasources.statistics-enabled:${wildfly.statistics-enabled:false}}">
                    <connection-url>jdbc:postgresql://${env.POSTGRES_HOST:172.17.0.1}/keycloak</connection-url>
                    <driver>postgresql</driver>
                    <security>
                        <user-name>${env.POSTGRES_USERNAME:postgres}</user-name>
                        <password>${env.POSTGRES_PASSWORD:""}</password>
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
        <subsystem xmlns="urn:jboss:domain:ee:6.0">
            <spec-descriptor-property-replacement>false</spec-descriptor-property-replacement>
            <concurrent>
                <context-services>
                    <context-service name="default" jndi-name="java:jboss/ee/concurrency/context/default" use-transaction-setup-provider="true"/>
                </context-services>
                <managed-thread-factories>
                    <managed-thread-factory name="default" jndi-name="java:jboss/ee/concurrency/factory/default" context-service="default"/>
                </managed-thread-factories>
                <managed-executor-services>
                    <managed-executor-service name="default" jndi-name="java:jboss/ee/concurrency/executor/default" context-service="default" hung-task-termination-period="0" hung-task-threshold="60000" keepalive-time="5000"/>
                </managed-executor-services>
                <managed-scheduled-executor-services>
                    <managed-scheduled-executor-service name="default" jndi-name="java:jboss/ee/concurrency/scheduler/default" context-service="default" hung-task-termination-period="0" hung-task-threshold="60000" keepalive-time="3000"/>
                </managed-scheduled-executor-services>
            </concurrent>
            <default-bindings
		context-service="java:jboss/ee/concurrency/context/default"
		datasource="java:jboss/datasources/KeycloakDS"
		managed-executor-service="java:jboss/ee/concurrency/executor/default"
		managed-scheduled-executor-service="java:jboss/ee/concurrency/scheduler/default"
                managed-thread-factory="java:jboss/ee/concurrency/factory/default"/>
        </subsystem>
        <subsystem xmlns="urn:wildfly:elytron:14.0" final-providers="combined-providers" disallowed-providers="OracleUcrypto">
            <providers>
                <aggregate-providers name="combined-providers">
                    <providers name="elytron"/>
                    <providers name="openssl"/>
                </aggregate-providers>
                <provider-loader name="elytron" module="org.wildfly.security.elytron"/>
                <provider-loader name="openssl" module="org.wildfly.openssl"/>
            </providers>
            <audit-logging>
                <file-audit-log name="local-audit" path="audit.log" relative-to="jboss.server.log.dir" format="JSON"/>
            </audit-logging>
            <security-domains>
                <security-domain name="ManagementDomain" default-realm="ManagementRealm" permission-mapper="default-permission-mapper">
                    <realm name="ManagementRealm" role-decoder="groups-to-roles"/>
                    <realm name="local" role-mapper="super-user-mapper"/>
                </security-domain>
                <security-domain name="ApplicationDomain" default-realm="ApplicationRealm" permission-mapper="default-permission-mapper">
                    <realm name="ApplicationRealm" role-decoder="groups-to-roles"/>
                    <realm name="local"/>
                </security-domain>
            </security-domains>
            <security-realms>
                <identity-realm name="local" identity="$local"/>
                <properties-realm name="ApplicationRealm">
                    <users-properties path="application-users.properties" relative-to="jboss.server.config.dir" digest-realm-name="ApplicationRealm"/>
                    <groups-properties path="application-roles.properties" relative-to="jboss.server.config.dir"/>
                </properties-realm>
                <properties-realm name="ManagementRealm">
                    <users-properties path="mgmt-users.properties" relative-to="jboss.server.config.dir" digest-realm-name="ManagementRealm"/>
                    <groups-properties path="mgmt-groups.properties" relative-to="jboss.server.config.dir"/>
                </properties-realm>
            </security-realms>
            <mappers>
                <simple-permission-mapper name="default-permission-mapper" mapping-mode="first">
                    <permission-mapping>
                        <principal name="anonymous"/>
                        <permission-set name="default-permissions"/>
                    </permission-mapping>
                    <permission-mapping match-all="true">
                        <permission-set name="login-permission"/>
                        <permission-set name="default-permissions"/>
                    </permission-mapping>
                </simple-permission-mapper>
                <constant-realm-mapper name="local" realm-name="local"/>
                <simple-role-decoder name="groups-to-roles" attribute="groups"/>
                <constant-role-mapper name="super-user-mapper">
                    <role name="SuperUser"/>
                </constant-role-mapper>
            </mappers>
            <permission-sets>
                <permission-set name="login-permission">
                    <permission class-name="org.wildfly.security.auth.permission.LoginPermission"/>
                </permission-set>
                <permission-set name="default-permissions">
                    <permission class-name="org.wildfly.extension.batch.jberet.deployment.BatchPermission" module="org.wildfly.extension.batch.jberet" target-name="*"/>
                    <permission class-name="org.wildfly.transaction.client.RemoteTransactionPermission" module="org.wildfly.transaction.client"/>
                    <permission class-name="org.jboss.ejb.client.RemoteEJBPermission" module="org.jboss.ejb-client"/>
                    <permission class-name="org.jboss.ejb.client.RemoteEJBPermission" module="org.jboss.ejb-client"/>
                </permission-set>
            </permission-sets>
            <http>
                <http-authentication-factory name="management-http-authentication" security-domain="ManagementDomain" http-server-mechanism-factory="global">
                    <mechanism-configuration>
                        <mechanism mechanism-name="DIGEST">
                            <mechanism-realm realm-name="ManagementRealm"/>
                        </mechanism>
                    </mechanism-configuration>
                </http-authentication-factory>
                <http-authentication-factory name="application-http-authentication" security-domain="ApplicationDomain" http-server-mechanism-factory="global">
                    <mechanism-configuration>
                        <mechanism mechanism-name="BASIC">
                            <mechanism-realm realm-name="ApplicationRealm"/>
                        </mechanism>
                    </mechanism-configuration>
                </http-authentication-factory>
                <provider-http-server-mechanism-factory name="global"/>
            </http>
            <sasl>
                <sasl-authentication-factory name="management-sasl-authentication" sasl-server-factory="configured" security-domain="ManagementDomain">
                    <mechanism-configuration>
                        <mechanism mechanism-name="JBOSS-LOCAL-USER" realm-mapper="local"/>
                        <mechanism mechanism-name="DIGEST-MD5">
                            <mechanism-realm realm-name="ManagementRealm"/>
                        </mechanism>
                    </mechanism-configuration>
                </sasl-authentication-factory>
                <sasl-authentication-factory name="application-sasl-authentication" sasl-server-factory="configured" security-domain="ApplicationDomain">
                    <mechanism-configuration>
                        <mechanism mechanism-name="JBOSS-LOCAL-USER" realm-mapper="local"/>
                        <mechanism mechanism-name="DIGEST-MD5">
                            <mechanism-realm realm-name="ApplicationRealm"/>
                        </mechanism>
                    </mechanism-configuration>
                </sasl-authentication-factory>
                <configurable-sasl-server-factory name="configured" sasl-server-factory="elytron">
                    <properties>
                        <property name="wildfly.sasl.local-user.default-user" value="$local"/>
                        <property name="wildfly.sasl.local-user.challenge-path" value="${jboss.server.temp.dir}/auth"/>
                    </properties>
                </configurable-sasl-server-factory>
                <mechanism-provider-filtering-sasl-server-factory name="elytron" sasl-server-factory="global">
                    <filters>
                        <filter provider-name="WildFlyElytron"/>
                    </filters>
                </mechanism-provider-filtering-sasl-server-factory>
                <provider-sasl-server-factory name="global"/>
            </sasl>
            <tls>
                <key-stores>
                    <key-store name="applicationKS">
                        <credential-reference clear-text="password"/>
                        <implementation type="JKS"/>
                        <file path="application.keystore" relative-to="jboss.server.config.dir"/>
                    </key-store>
                </key-stores>
                <key-managers>
                    <key-manager name="applicationKM" key-store="applicationKS" generate-self-signed-certificate-host="localhost">
                        <credential-reference clear-text="password"/>
                    </key-manager>
                </key-managers>
                <server-ssl-contexts>
                    <server-ssl-context name="applicationSSC" key-manager="applicationKM"/>
                </server-ssl-contexts>
            </tls>
        </subsystem>
        <subsystem xmlns="urn:jboss:domain:infinispan:13.0">
            <cache-container name="ejb" default-cache="passivation" marshaller="PROTOSTREAM" aliases="sfsb" modules="org.wildfly.clustering.ejb.infinispan">
                <local-cache name="passivation">
                    <locking isolation="REPEATABLE_READ"/>
                    <transaction mode="BATCH"/>
                    <file-store passivation="true" purge="false"/>
                </local-cache>
            </cache-container>
            <cache-container name="keycloak" marshaller="JBOSS" modules="org.keycloak.keycloak-model-infinispan">
                <local-cache name="realms">
                    <heap-memory size="10000"/>
                </local-cache>
                <local-cache name="users">
                    <heap-memory size="10000"/>
                </local-cache>
                <local-cache name="sessions"/>
                <local-cache name="authenticationSessions"/>
                <local-cache name="offlineSessions"/>
                <local-cache name="clientSessions"/>
                <local-cache name="offlineClientSessions"/>
                <local-cache name="loginFailures"/>
                <local-cache name="work"/>
                <local-cache name="authorization">
                    <heap-memory size="10000"/>
                </local-cache>
                <local-cache name="keys">
                    <heap-memory size="1000"/>
                    <expiration max-idle="3600000"/>
                </local-cache>
                <local-cache name="actionTokens">
                    <heap-memory size="-1"/>
                    <expiration interval="300000" max-idle="-1"/>
                </local-cache>
            </cache-container>
            <cache-container name="server" default-cache="default" marshaller="PROTOSTREAM" modules="org.wildfly.clustering.server">
                <local-cache name="default">
                    <transaction mode="BATCH"/>
                </local-cache>
            </cache-container>
            <cache-container name="web" default-cache="passivation" marshaller="PROTOSTREAM" modules="org.wildfly.clustering.web.infinispan">
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
            <cache-container name="hibernate" marshaller="JBOSS" modules="org.infinispan.hibernate-cache">
                <local-cache name="entity">
                    <heap-memory size="10000"/>
                    <expiration max-idle="100000"/>
                </local-cache>
                <local-cache name="local-query">
                    <heap-memory size="10000"/>
                    <expiration max-idle="100000"/>
                </local-cache>
                <local-cache name="timestamps"/>
            </cache-container>
        </subsystem>
        <subsystem xmlns="urn:jboss:domain:io:3.0">
            <worker name="default"/>
            <buffer-pool name="default"/>
        </subsystem>
        <subsystem xmlns="urn:jboss:domain:jaxrs:2.0"/>
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
            <jpa default-extended-persistence-inheritance="DEEP"/>
        </subsystem>
        <subsystem xmlns="urn:jboss:domain:keycloak-server:1.1">
            <web-context>auth</web-context>
            <providers>
                <provider>
                    classpath:${jboss.home.dir}/providers/*
                </provider>
            </providers>
            <master-realm-name>master</master-realm-name>
            <scheduled-task-interval>900</scheduled-task-interval>
            <theme>
                <staticMaxAge>2592000</staticMaxAge>
                <cacheThemes>${env.KEYCLOAK_CACHE_THEMES:true}</cacheThemes>
                <cacheTemplates>${env.KEYCLOAK_CACHE_TEMPLATES:true}</cacheTemplates>
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
                        <property name="frontendUrl" value="${env.KEYCLOAK_FRONTEND_URL:}"/>
                        <property name="forceBackendUrlToFrontendUrl" value="false"/>
                    </properties>
                </provider>
            </spi>
        </subsystem>
        <subsystem xmlns="urn:jboss:domain:mail:4.0">
            <mail-session name="default" jndi-name="java:jboss/mail/Default">
                <smtp-server outbound-socket-binding-ref="mail-smtp"/>
            </mail-session>
        </subsystem>
        <subsystem xmlns="urn:jboss:domain:naming:2.0">
            <remote-naming/>
        </subsystem>
        <subsystem xmlns="urn:jboss:domain:remoting:4.0">
            <http-connector name="http-remoting-connector" connector-ref="default" sasl-authentication-factory="application-sasl-authentication"/>
        </subsystem>
        <subsystem xmlns="urn:jboss:domain:request-controller:1.0"/>
        <subsystem xmlns="urn:jboss:domain:security-manager:1.0">
            <deployment-permissions>
                <maximum-set>
                    <permission class="java.security.AllPermission"/>
                </maximum-set>
            </deployment-permissions>
        </subsystem>
        <subsystem xmlns="urn:jboss:domain:transactions:6.0">
            <core-environment node-identifier="${jboss.tx.node.id:1}">
                <process-id>
                    <uuid/>
                </process-id>
            </core-environment>
            <recovery-environment socket-binding="txn-recovery-environment" status-socket-binding="txn-status-manager"/>
            <coordinator-environment statistics-enabled="${wildfly.transactions.statistics-enabled:${wildfly.statistics-enabled:false}}"/>
            <object-store path="tx-object-store" relative-to="jboss.server.data.dir"/>
        </subsystem>
        <subsystem xmlns="urn:jboss:domain:undertow:12.0" default-server="default-server" default-virtual-host="default-host" default-servlet-container="default" default-security-domain="other" statistics-enabled="${wildfly.undertow.statistics-enabled:${wildfly.statistics-enabled:false}}">
            <buffer-cache name="default"/>
            <server name="default-server">
                <http-listener name="default" socket-binding="http" proxy-address-forwarding="true"/>
                <host name="default-host" alias="localhost">
                    <location name="/" handler="welcome-content"/>
                    <http-invoker http-authentication-factory="application-http-authentication"/>
                </host>
            </server>
            <servlet-container name="default">
                <jsp-config/>
                <session-cookie http-only="true" secure="true"/>
                <websockets/>
            </servlet-container>
            <handlers>
                <file name="welcome-content" path="${jboss.home.dir}/welcome-content"/>
            </handlers>
            <application-security-domains>
                <application-security-domain name="other" security-domain="ApplicationDomain"/>
            </application-security-domains>
        </subsystem>
        <subsystem xmlns="urn:jboss:domain:weld:4.0"/>
    </profile>
    <interfaces>
        <interface name="public">
            <inet-address value="0.0.0.0"/>
        </interface>
    </interfaces>
    <socket-binding-group name="standard-sockets" default-interface="public" port-offset="${jboss.socket.binding.port-offset:0}">
        <socket-binding name="http" port="${env.HTTP_PORT:8080}"/>
        <socket-binding name="txn-recovery-environment" port="4712"/>
        <socket-binding name="txn-status-manager" port="4713"/>
        <outbound-socket-binding name="mail-smtp">
            <remote-destination host="${jboss.mail.server.host:localhost}" port="${jboss.mail.server.port:25}"/>
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

groupadd --system --gid 20000 docker-machines
useradd --system --create-home --gid docker-machines --uid 20001 keycloak
chown -R keycloak:docker-machines /opt/keycloak
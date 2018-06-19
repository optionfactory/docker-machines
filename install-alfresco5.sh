#!/bin/bash -e

if [ "$#" -eq 0 ]; then
    echo "missing argument: alfresco setup path"
    exit 1
fi


#http://docs.alfresco.com/5.0/concepts/install-lolibfiles.html

if [ -f /usr/bin/apt-get  ]; then
    DEBIAN_FRONTEND=noninteractive apt-get -y -q update
    DEBIAN_FRONTEND=noninteractive apt-get -y -q install libcups2 libcupscgi1 libcupsimage2 libcupsmime1 libcupsppdc1
    DEBIAN_FRONTEND=noninteractive apt-get -y -q install libdbus-glib-1-2 fontconfig hostname libice6 libsm6 libxext6 libxinerama1 libxrender1 grep patch
    DEBIAN_FRONTEND=noninteractive apt-get -y -q autoclean
    DEBIAN_FRONTEND=noninteractive apt-get -y -q autoremove
    rm -rf /var/lib/apt/lists/*
elif [ -f /usr/bin/zypper ] ; then
    zypper -n -q install cups-libs dbus-1-glib fontconfig net-tools libICE6  libSM6 libXext6 libXinerama1 libXrender1 grep patch
    zypper -n -q clean --all
elif [ -f /usr/bin/yum ] ; then
    yum install -q -y cups-libs dbus-glib fontconfig hostname libICE libSM libXext libXinerama libXrender grep patch
    yum clean all
    rm -rf /var/cache/yum    
else
    echo "unknown or missing package manager"
    exit 1
fi



mkdir -p /opt/alfresco
cd /tmp
chmod +x /tmp/alfresco-*/alfresco-installer.bin
sync #a docker bug https://github.com/docker/docker/issues/9547
${1}/alfresco-installer.bin --mode unattended --prefix /opt/alfresco --alfresco_admin_password admin


cat <<-'EOF' > /opt/alfresco/tomcat/shared/classes/alfresco-global.properties

	###############################
	## Common Alfresco Properties #
	###############################

	dir.root=/opt/alfresco/alf_data

	alfresco.context=alfresco
	alfresco.host=127.0.0.1
	alfresco.port=8080
	alfresco.protocol=http

	share.context=share
	share.host=127.0.0.1
	share.port=8080
	share.protocol=http

	### database connection properties ###
	db.driver=org.postgresql.Driver
	db.username=alfresco
	db.password=admin
	db.name=alfresco
	db.url=jdbc:postgresql://localhost:5432/alfresco
	# Note: your database must also be able to accept at least this many connections.  Please see your database documentation for instructions on how to configure this.
	db.pool.max=275
	db.pool.validate.query=SELECT 1

	# The server mode. Set value here
	# UNKNOWN | TEST | BACKUP | PRODUCTION
	system.serverMode=PRODUCTION

	### FTP Server Configuration ###
	ftp.port=21

	### RMI registry port for JMX ###
	alfresco.rmi.services.port=50500

	### External executable locations ###
	ooo.exe=/opt/alfresco/libreoffice/program/soffice.bin
	ooo.enabled=true
	ooo.port=8100
	img.root=/opt/alfresco/common
	img.dyn=${img.root}/lib
	img.exe=${img.root}/bin/convert

	jodconverter.enabled=false
	jodconverter.officeHome=/opt/alfresco/libreoffice
	jodconverter.portNumbers=8100

	### Initial admin password ###
	alfresco_user_store.adminpassword=209c6174da490caeb422f3fa5a7ae634

	### E-mail site invitation setting ###
	notification.email.siteinvite=false

	### License location ###
	dir.license.external=/opt/alfresco

	### Solr indexing ###
	index.subsystem.name=solr4
	dir.keystore=${dir.root}/keystore
	solr.host=localhost
	solr.port.ssl=8443

	### Allow extended ResultSet processing
	security.anyDenyDenies=false

	### Smart Folders Config Properties ###
	smart.folders.enabled=false

	### Remote JMX (Default: disabled) ###
	alfresco.jmx.connector.enabled=falsemail.host=localhost
	mail.port=25
	mail.from.default=alfresco@alfresco.org
	mail.protocol=smtp
	mail.smtp.auth=false
	mail.smtp.starttls.enable=false
	mail.smtps.auth=false
	mail.smtps.starttls.enable=false
	cifs.enabled=true
	cifs.Server.Name=localhost
	cifs.domain=WORKGROUP
	cifs.hostannounce=true
	cifs.broadcast=0.0.0.255
	cifs.ipv6.enabled=false
	nfs.enabled=true
	authentication.chain=alfrescoNtlm1:alfrescoNtlm
	dir.contentstore=/opt/alfresco/alf_data//contentstore
	dir.contentstore.deleted=/opt/alfresco/alf_data//contentstore.deleted
EOF

mkdir -p /opt/alfresco/tomcat/shared/classes/alfresco/extension/subsystems/Authentication/ldap/ldap1/
cat <<-'EOF' > /opt/alfresco/tomcat/shared/classes/alfresco/extension/subsystems/Authentication/ldap/ldap1/ldap-authentication.properties
	# This flag enables use of this LDAP subsystem for authentication. It may be
	# that this subsytem should only be used for synchronization, in which case
	# this flag should be set to false.
	ldap.authentication.active=true

	#
	# This properties file brings together the common options for LDAP authentication rather than editing the bean definitions
	#
	ldap.authentication.allowGuestLogin=false
	# How to map the user id entered by the user to that passed through to LDAP
	# - simple
	#    - this must be a DN and would be something like
	#      uid=%s,ou=People,dc=company,dc=com
	# - digest
	#    - usually pass through what is entered
	#      %s
	# If not set, an LDAP query involving ldap.synchronization.personQuery and ldap.synchronization.userIdAttributeName will
	# be performed to resolve the DN dynamically. This allows directories to be structured and doesn't require the user ID to
	# appear in the DN.
	ldap.authentication.userNameFormat=@@LDAP_AUTH_USERNAMEFORMAT@@

	# The LDAP context factory to use
	ldap.authentication.java.naming.factory.initial=com.sun.jndi.ldap.LdapCtxFactory

	# The URL to connect to the LDAP server
	ldap.authentication.java.naming.provider.url=@@LDAP_URL@@

	# The authentication mechanism to use for password validation
	ldap.authentication.java.naming.security.authentication=simple

	# Escape commas entered by the user at bind time
	# Useful when using simple authentication and the CN is part of the DN and contains commas
	ldap.authentication.escapeCommasInBind=false

	# Escape commas entered by the user when setting the authenticated user
	# Useful when using simple authentication and the CN is part of the DN and contains commas, and the escaped \, is
	# pulled in as part of an LDAP sync
	# If this option is set to true it will break the default home folder provider as space names can not contain \
	ldap.authentication.escapeCommasInUid=false

	# Comma separated list of user names who should be considered administrators by default
	ldap.authentication.defaultAdministratorUserNames=@@LDAP_DEFAULT_ADMINS@@

	# This flag enables use of this LDAP subsystem for user and group
	# synchronization. It may be that this subsytem should only be used for
	# authentication, in which case this flag should be set to false.
	ldap.synchronization.active=true

	# The authentication mechanism to use for synchronization
	ldap.synchronization.java.naming.security.authentication=simple

	# The default principal to use (only used for LDAP sync)
	ldap.synchronization.java.naming.security.principal=@@LDAP_SECURITY_PRINCIPAL@@

	# The password for the default principal (only used for LDAP sync)
	ldap.synchronization.java.naming.security.credentials=@@LDAP_SECURITY_CREDENTIALS@@

	# If positive, this property indicates that RFC 2696 paged results should be
	# used to split query results into batches of the specified size. This
	# overcomes any size limits imposed by the LDAP server.
	ldap.synchronization.queryBatchSize=0

	# If positive, this property indicates that range retrieval should be used to fetch
	# multi-valued attributes (such as member) in batches of the specified size.
	# Overcomes any size limits imposed by Active Directory.
	ldap.synchronization.attributeBatchSize=0

	# The query to select all objects that represent the groups to import.
	ldap.synchronization.groupQuery=(objectclass=posixGroup)

	# The query to select objects that represent the groups to import that have changed since a certain time.
	ldap.synchronization.groupDifferentialQuery=(&(objectclass=posixGroup)(!(modifyTimestamp<={0})))

	# The query to select all objects that represent the users to import.
	ldap.synchronization.personQuery=(objectclass=inetOrgPerson)

	# The query to select objects that represent the users to import that have changed since a certain time.
	ldap.synchronization.personDifferentialQuery=(&(objectclass=inetOrgPerson)(!(modifyTimestamp<={0})))

	# The group search base restricts the LDAP group query to a sub section of tree on the LDAP server.
	ldap.synchronization.groupSearchBase=@@LDAP_GROUP_SEARCHBASE@@

	# The user search base restricts the LDAP user query to a sub section of tree on the LDAP server.
	ldap.synchronization.userSearchBase=@@LDAP_USER_SEARCHBASE@@

	# The name of the operational attribute recording the last update time for a group or user.
	ldap.synchronization.modifyTimestampAttributeName=modifyTimestamp

	# The timestamp format. Unfortunately, this varies between directory servers.
	ldap.synchronization.timestampFormat=yyyyMMddHHmmss'Z'

	# The attribute name on people objects found in LDAP to use as the uid in Alfresco
	ldap.synchronization.userIdAttributeName=uid

	# The attribute on person objects in LDAP to map to the first name property in Alfresco
	ldap.synchronization.userFirstNameAttributeName=givenName

	# The attribute on person objects in LDAP to map to the last name property in Alfresco
	ldap.synchronization.userLastNameAttributeName=sn

	# The attribute on person objects in LDAP to map to the email property in Alfresco
	ldap.synchronization.userEmailAttributeName=mail

	# The attribute on person objects in LDAP to map to the organizational id  property in Alfresco
	ldap.synchronization.userOrganizationalIdAttributeName=o

	# The default home folder provider to use for people created via LDAP import
	ldap.synchronization.defaultHomeFolderProvider=userHomesHomeFolderProvider

	# The attribute on LDAP group objects to map to the authority name property in Alfresco
	ldap.synchronization.groupIdAttributeName=cn

	# The attribute on LDAP group objects to map to the authority display name property in Alfresco
	ldap.synchronization.groupDisplayNameAttributeName=description

	# The group type in LDAP
	ldap.synchronization.groupType=posixGroup

	# The person type in LDAP
	ldap.synchronization.personType=inetOrgPerson

	# The attribute in LDAP on group objects that defines the DN for its members
	ldap.synchronization.groupMemberAttributeName=memberUid

	# If true progress estimation is enabled. When enabled, the user query has to be run twice in order to count entries.
	ldap.synchronization.enableProgressEstimation=true
EOF

mkdir -p /opt/alfresco/tomcat/shared/classes/alfresco/extension/subsystems/Authentication/ldap-ad/ldap1/
cat <<-'EOF' > /opt/alfresco/tomcat/shared/classes/alfresco/extension/subsystems/Authentication/ldap-ad/ldap1/ldap-ad-authentication.properties
	# This flag enables use of this LDAP subsystem for authentication. It may be
	# that this subsytem should only be used for synchronization, in which case
	# this flag should be set to false.
	ldap.authentication.active=true

	#
	# This properties file brings together the common options for LDAP authentication rather than editing the bean definitions
	#
	ldap.authentication.allowGuestLogin=false

	# How to map the user id entered by the user to taht passed through to LDAP
	# In Active Directory, this can either be the user principal name (UPN) or DN.
	# UPNs are in the form <sAMAccountName>@domain and are held in the userPrincipalName attribute of a user
	ldap.authentication.userNameFormat=@@LDAP_AUTH_USERNAMEFORMAT@@

	# The LDAP context factory to use
	ldap.authentication.java.naming.factory.initial=com.sun.jndi.ldap.LdapCtxFactory

	# The URL to connect to the LDAP server
	ldap.authentication.java.naming.provider.url=@@LDAP_URL@@

	#Custom Socket Factory.
	#ldap.java.naming.ldap.factory.socket=org.alfresco.repo.security.authentication.ldap.AlfrescoLdapSSLSocketFactory

	# The authentication mechanism to use for password validation
	ldap.authentication.java.naming.security.authentication=simple

	# Escape commas entered by the user at bind time
	# Useful when using simple authentication and the CN is part of the DN and contains commas
	ldap.authentication.escapeCommasInBind=false

	# Escape commas entered by the user when setting the authenticated user
	# Useful when using simple authentication and the CN is part of the DN and contains commas, and the escaped \, is
	# pulled in as part of an LDAP sync
	# If this option is set to true it will break the default home folder provider as space names can not contain \
	ldap.authentication.escapeCommasInUid=false

	# Comma separated list of user names who should be considered administrators by default
	ldap.authentication.defaultAdministratorUserNames=@@LDAP_DEFAULT_ADMINS@@

	# This flag enables use of this LDAP subsystem for user and group
	# synchronization. It may be that this subsytem should only be used for
	# authentication, in which case this flag should be set to false.
	ldap.synchronization.active=true

	# The authentication mechanism to use for synchronization
	ldap.synchronization.java.naming.security.authentication=simple

	# The default principal to bind with (only used for LDAP sync). This should be a UPN or DN
	ldap.synchronization.java.naming.security.principal=@@LDAP_SECURITY_PRINCIPAL@@

	# The password for the default principal (only used for LDAP sync)
	ldap.synchronization.java.naming.security.credentials=@@LDAP_SECURITY_CREDENTIALS@@

	# If positive, this property indicates that RFC 2696 paged results should be
	# used to split query results into batches of the specified size. This
	# overcomes any size limits imposed by the LDAP server.
	ldap.synchronization.queryBatchSize=1000

	# If positive, this property indicates that range retrieval should be used to fetch
	# multi-valued attributes (such as member) in batches of the specified size.
	# Overcomes any size limits imposed by Active Directory.
	ldap.synchronization.attributeBatchSize=1000

	# The query to select all objects that represent the groups to import.
	ldap.synchronization.groupQuery=(objectclass\=group)

	# The query to select objects that represent the groups to import that have changed since a certain time.
	ldap.synchronization.groupDifferentialQuery=(&(objectclass\=group)(!(whenChanged<\={0})))

	# The query to select all objects that represent the users to import.
	ldap.synchronization.personQuery=(&(objectclass\=user)(userAccountControl\:1.2.840.113556.1.4.803\:\=512))

	# The query to select objects that represent the users to import that have changed since a certain time.
	ldap.synchronization.personDifferentialQuery=(&(objectclass\=user)(userAccountControl\:1.2.840.113556.1.4.803\:\=512)(!(whenChanged<\={0})))

	# The group search base restricts the LDAP group query to a sub section of tree on the LDAP server.
	ldap.synchronization.groupSearchBase=@@LDAP_GROUP_SEARCHBASE@@

	# The user search base restricts the LDAP user query to a sub section of tree on the LDAP server.
	ldap.synchronization.userSearchBase=@@LDAP_USER_SEARCHBASE@@

	# The name of the operational attribute recording the last update time for a group or user.
	ldap.synchronization.modifyTimestampAttributeName=whenChanged

	# The timestamp format. Unfortunately, this varies between directory servers.
	ldap.synchronization.timestampFormat=yyyyMMddHHmmss'.0Z'

	# The attribute name on people objects found in LDAP to use as the uid in Alfresco
	ldap.synchronization.userIdAttributeName=sAMAccountName

	# The attribute on person objects in LDAP to map to the first name property in Alfresco
	ldap.synchronization.userFirstNameAttributeName=givenName

	# The attribute on person objects in LDAP to map to the last name property in Alfresco
	ldap.synchronization.userLastNameAttributeName=sn

	# The attribute on person objects in LDAP to map to the email property in Alfresco
	ldap.synchronization.userEmailAttributeName=mail

	# The attribute on person objects in LDAP to map to the organizational id  property in Alfresco
	ldap.synchronization.userOrganizationalIdAttributeName=company

	# The default home folder provider to use for people created via LDAP import
	ldap.synchronization.defaultHomeFolderProvider=largeHomeFolderProvider

	# The attribute on LDAP group objects to map to the authority name property in Alfresco
	ldap.synchronization.groupIdAttributeName=cn

	# The attribute on LDAP group objects to map to the authority display name property in Alfresco
	ldap.synchronization.groupDisplayNameAttributeName=displayName

	# The group type in LDAP
	ldap.synchronization.groupType=group

	# The person type in LDAP
	ldap.synchronization.personType=user

	# The attribute in LDAP on group objects that defines the DN for its members
	ldap.synchronization.groupMemberAttributeName=member

	# If true progress estimation is enabled. When enabled, the user query has to be run twice in order to count entries.
	ldap.synchronization.enableProgressEstimation=true
EOF

#mkdir -p /opt/alfresco/tomcat/webapps/ROOT
#echo '<% response.sendRedirect("/share"); %>' > /opt/alfresco/tomcat/webapps/ROOT/index.jsp


groupadd -r alfresco
useradd -r -m -g alfresco alfresco

chown -R alfresco:alfresco /opt/alfresco

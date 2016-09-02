#!/bin/bash -e

if [ "$#" -eq 0 ]; then
    echo "missing argument: db2setup directory"
    exit 1
fi

distro="unknown"

if [ -f /etc/debian_version ] ; then
    distro="debian"
fi
if [ -f /etc/lsb-release ] ; then
    distro="ubuntu"
fi

if [ "debian" == "${distro}" ] ; then
    echo "working around debian not being supported"
    echo "DISTRIB_ID=Ubuntu"     >  /etc/lsb-release
    echo "DISTRIB_RELEASE=14.04" >> /etc/lsb-release
fi

#http://www.ibm.com/support/knowledgecenter/SSEPGG_9.5.0/com.ibm.db2.luw.qb.server.doc/doc/r0008865.html
if [ -f /usr/bin/apt-get ] ; then
    DEBIAN_FRONTEND=noninteractive dpkg --add-architecture i386
    DEBIAN_FRONTEND=noninteractive apt-get -y -q update
    DEBIAN_FRONTEND=noninteractive apt-get -y -q install libpam0g:i386 libaio1 libstdc++6 lib32stdc++6 binutils file libxml2
    DEBIAN_FRONTEND=noninteractive apt-get -y -q install strace net-tools
    DEBIAN_FRONTEND=noninteractive apt-get -y -q autoclean
    DEBIAN_FRONTEND=noninteractive apt-get -y -q autoremove
    rm -rf /var/lib/apt/lists/*
    #looked up in the wrong place
    ln -s /lib/i386-linux-gnu/libpam.so.0 /lib/libpam.so.0    
elif [ -f /usr/bin/zypper ] ; then
    zypper -n -q install pam libstdc++6 libaio1 ksh binutils file libxml2
    zypper -n -q clean --all
elif [ -f /usr/bin/yum ] ; then
    yum install -q -y pam libaio libario.i386 compat-libstdc++-33 compat-libstdc++-33.i386 ksh binutils file libxml2
    yum clean all
else 
    echo "unknown or missing package manager"
    exit 1
fi

 


rm -rf /var/lib/apt/lists/*

cat <<-'EOF' > /tmp/responses.rsp
	LIC_AGREEMENT = ACCEPT
	PROD = EXPRESS_C
	FILE = /opt/ibm/db2/
	INSTALL_TYPE = COMPACT
	LANG = EN
EOF

${1}/db2setup -r /tmp/responses.rsp

groupadd db2iadm1
groupadd db2fadm1
groupadd dasadm1
useradd -g db2iadm1 -m -d /home/db2inst1 db2inst1
useradd -g db2fadm1 -m -d /home/db2fenc1 db2fenc1
useradd -g dasadm1 -m -d /home/dasusr1 dasusr1
echo db2inst1:db2inst1 | chpasswd
echo db2fenc1:db2fenc1 | chpasswd
echo dasusr1:dasusr1 | chpasswd

#creates a DB2 administration server
/opt/ibm/db2/instance/dascrt -u dasusr1

if [ "debian" == "${distro}" ] ; then
    rm -rf /etc/lsb-release
fi

mkdir -p /sql-init.d/
chown -R db2inst1:db2iadm1 /sql-init.d/
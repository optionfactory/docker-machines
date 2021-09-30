#!/bin/bash -e
echo "installing jdk (AdoptJDK)"

if [ ! -f /usr/sbin/update-alternatives ]; then
    ln -s /usr/sbin/update-alternatives  /usr/sbin/alternatives
fi

mkdir -p /usr/java
cp -R /tmp/jdk-* /usr/java/
jdkdir=$(readlink -f /usr/java/jdk-*)
jdkbindir=$(readlink -f ${jdkdir}/bin)
jdkmajorversion=$(basename $jdkdir | sed 's/jdk-\([0-9]\+\)[.+].*/\1/')

chown -R root:root ${jdkdir}

echo "installing alternatives (java) for AdoptJDK jdk (${jdkmajorversion})"
update-alternatives --install \
	/usr/bin/java java "$jdkbindir/java" ${jdkmajorversion} \
    --slave /usr/bin/jar jar "$jdkbindir/jar" \
    --slave /usr/bin/jarsigner jarsigner "$jdkbindir/jarsigner" \
    --slave /usr/bin/javac javac "$jdkbindir/javac" \
    --slave /usr/bin/javadoc javadoc "$jdkbindir/javadoc" \
    --slave /usr/bin/javap javap "$jdkbindir/javap" \
    --slave /usr/bin/jcmd jcmd "$jdkbindir/jcmd" \
    --slave /usr/bin/jconsole jconsole "$jdkbindir/jconsole" \
    --slave /usr/bin/jdb jdb "$jdkbindir/jdb" \
    --slave /usr/bin/jdeprscan jdeprscan "$jdkbindir/jdeprscan" \
    --slave /usr/bin/jdeps jdeps "$jdkbindir/jdeps" \
    --slave /usr/bin/jfr jfr "$jdkbindir/jfr" \
    --slave /usr/bin/jhsdb jhsdb "$jdkbindir/jhsdb" \
    --slave /usr/bin/jimage jimage "$jdkbindir/jimage" \
    --slave /usr/bin/jinfo jinfo "$jdkbindir/jinfo" \
    --slave /usr/bin/jlink jlink "$jdkbindir/jlink" \
    --slave /usr/bin/jmap jmap "$jdkbindir/jmap" \
    --slave /usr/bin/jmod jmod "$jdkbindir/jmod" \
    --slave /usr/bin/jpackage jpackage "$jdkbindir/jpackage" \
    --slave /usr/bin/jps jps "$jdkbindir/jps" \
    --slave /usr/bin/jrunscript jrunscript "$jdkbindir/jrunscript" \
    --slave /usr/bin/jshell jshell "$jdkbindir/jshell" \
    --slave /usr/bin/jstack jstack "$jdkbindir/jstack" \
    --slave /usr/bin/jstat jstat "$jdkbindir/jstat" \
    --slave /usr/bin/jstatd jstatd "$jdkbindir/jstatd" \
    --slave /usr/bin/keytool keytool "$jdkbindir/keytool" \
    --slave /usr/bin/rmiregistry rmiregistry "$jdkbindir/rmiregistry" \
    --slave /usr/bin/serialver serialver "$jdkbindir/serialver" \

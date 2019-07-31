#!/bin/bash -e
echo "installing jdk (AdoptJDK)"

if [ ! -f /usr/sbin/update-alternatives ]; then
    ln -s /usr/sbin/update-alternatives  /usr/sbin/alternatives
fi

mkdir -p /usr/java
cp -R /tmp/jdk-11* /usr/java/
jdkdir=$(readlink -f /usr/java/jdk-11*)
jdkbindir=$(readlink -f ${jdkdir}/bin)

chown -R root:root ${jdkdir}

echo "installing alternatives (java) for AdoptJDK jdk"
update-alternatives --install \
	/usr/bin/java java $jdkbindir/java 11 \
	--slave /usr/bin/javac javac $jdkbindir/javac \
    --slave /usr/bin/jaotc jaotc $jdkbindir/jaotc \
    --slave /usr/bin/jar jar $jdkbindir/jar \
    --slave /usr/bin/jarsigner jarsigner $jdkbindir/jarsigner \
    --slave /usr/bin/javadoc javadoc $jdkbindir/javadoc \
    --slave /usr/bin/javap javap $jdkbindir/javap \
    --slave /usr/bin/jcmd jcmd $jdkbindir/jcmd \
    --slave /usr/bin/jconsole jconsole $jdkbindir/jconsole \
    --slave /usr/bin/jdb jdb $jdkbindir/jdb \
    --slave /usr/bin/jdeprscan jdeprscan $jdkbindir/jdeprscan \
    --slave /usr/bin/jdeps jdeps $jdkbindir/jdeps \
    --slave /usr/bin/jhsdb jhsdb $jdkbindir/jhsdb \
    --slave /usr/bin/jimage jimage $jdkbindir/jimage \
    --slave /usr/bin/jinfo jinfo $jdkbindir/jinfo \
    --slave /usr/bin/jjs jjs $jdkbindir/jjs \
    --slave /usr/bin/jlink jlink $jdkbindir/jlink \
    --slave /usr/bin/jmap jmap $jdkbindir/jmap \
    --slave /usr/bin/jmod jmod $jdkbindir/jmod \
    --slave /usr/bin/jps jps $jdkbindir/jps \
    --slave /usr/bin/jrunscript jrunscript $jdkbindir/jrunscript \
    --slave /usr/bin/jshell jshell $jdkbindir/jshell \
    --slave /usr/bin/jstack jstack $jdkbindir/jstack \
    --slave /usr/bin/jstat jstat $jdkbindir/jstat \
    --slave /usr/bin/jstatd jstatd $jdkbindir/jstatd \
    --slave /usr/bin/keytool keytool $jdkbindir/keytool \
    --slave /usr/bin/pack200 pack200 $jdkbindir/pack200 \
    --slave /usr/bin/rmic rmic $jdkbindir/rmic \
    --slave /usr/bin/rmid rmid $jdkbindir/rmid \
    --slave /usr/bin/rmiregistry rmiregistry $jdkbindir/rmiregistry \
    --slave /usr/bin/serialver serialver $jdkbindir/serialver \
    --slave /usr/bin/unpack200 unpack200 $jdkbindir/unpack200

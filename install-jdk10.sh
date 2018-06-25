#!/bin/bash -e
echo "installing jdk (Oracle)"

if [ ! -f /usr/sbin/update-alternatives ]; then
    ln -s /usr/sbin/update-alternatives  /usr/sbin/alternatives
fi

mkdir -p /usr/java
cp -R /tmp/jdk-10* /usr/java/
jdkdir=$(readlink -f /usr/java/jdk-10*)
jdkbindir=$(readlink -f ${jdkdir}/bin)

chown -R root:root ${jdkdir}

echo "installing alternatives (java) for oracle jdk"
update-alternatives --install \
	/usr/bin/java java $jdkbindir/java 10 \
	--slave /usr/bin/javac javac $jdkbindir/javac \
	--slave /usr/bin/appletviewer appletviewer $jdkbindir/appletviewer \
	--slave /usr/bin/idlj idlj $jdkbindir/idlj \
    --slave /usr/bin/jaotc jaotc $jdkbindir/jaotc \
	--slave /usr/bin/jar jar $jdkbindir/jar \
	--slave /usr/bin/jarsigner jarsigner $jdkbindir/jarsigner \
	--slave /usr/bin/javadoc javadoc $jdkbindir/javadoc \
	--slave /usr/bin/javap javap $jdkbindir/javap \
	--slave /usr/bin/javapackager javapackager $jdkbindir/javapackager \
	--slave /usr/bin/javaws javaws $jdkbindir/javaws \
	--slave /usr/bin/jcmd jcmd $jdkbindir/jcmd \
	--slave /usr/bin/jconsole jconsole $jdkbindir/jconsole \
	--slave /usr/bin/jcontrol jcontrol $jdkbindir/jcontrol \
	--slave /usr/bin/jdb jdb $jdkbindir/jdb \
    --slave /usr/bin/jdeprscan jdeprscan $jdkbindir/jdeprscan \
	--slave /usr/bin/jdeps jdeps $jdkbindir/jdeps \
    --slave /usr/bin/jhsdb jhsdb $jdkbindir/jhsdb \
    --slave /usr/bin/jimage jimage $jdkbindir/jimage \
	--slave /usr/bin/jinfo jinfo $jdkbindir/jinfo \
	--slave /usr/bin/jjs jjs $jdkbindir/jjs \
    --slave /usr/bin/jlink jlink $jdkbindir/jlink \
	--slave /usr/bin/jmap jmap $jdkbindir/jmap \
	--slave /usr/bin/jmc jmc $jdkbindir/jmc \
    --slave /usr/bin/jmod jmod $jdkbindir/jmod \
	--slave /usr/bin/jps jps $jdkbindir/jps \
	--slave /usr/bin/jrunscript jrunscript $jdkbindir/jrunscript \
    --slave /usr/bin/jshell jshell $jdkbindir/jshell \
	--slave /usr/bin/jstack jstack $jdkbindir/jstack \
	--slave /usr/bin/jstat jstat $jdkbindir/jstat \
	--slave /usr/bin/jstatd jstatd $jdkbindir/jstatd \
    --slave /usr/bin/jweblauncher jweblauncher $jdkbindir/jweblauncher \
	--slave /usr/bin/keytool keytool $jdkbindir/keytool \
	--slave /usr/bin/orbd orbd $jdkbindir/orbd \
	--slave /usr/bin/pack200 pack200 $jdkbindir/pack200 \
	--slave /usr/bin/rmic rmic $jdkbindir/rmic \
	--slave /usr/bin/rmid rmid $jdkbindir/rmid \
	--slave /usr/bin/rmiregistry rmiregistry $jdkbindir/rmiregistry \
	--slave /usr/bin/schemagen schemagen $jdkbindir/schemagen \
	--slave /usr/bin/serialver serialver $jdkbindir/serialver \
	--slave /usr/bin/servertool servertool $jdkbindir/servertool \
	--slave /usr/bin/tnameserv tnameserv $jdkbindir/tnameserv \
	--slave /usr/bin/unpack200 unpack200 $jdkbindir/unpack200 \
	--slave /usr/bin/wsgen wsgen $jdkbindir/wsgen \
	--slave /usr/bin/wsimport wsimport $jdkbindir/wsimport \
	--slave /usr/bin/xjc xjc $jdkbindir/xjc

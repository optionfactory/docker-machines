#!/bin/bash -e
MAJOR_VERSION=8
MINOR_VERSION=102
BUILD=b14
VERSION=${MAJOR_VERSION}u${MINOR_VERSION}


echo "installing oracle jdk ${VERSION}-${BUILD}"

if [ ! -f /usr/sbin/update-alternatives ]; then
    ln -s /usr/sbin/update-alternatives  /usr/sbin/alternatives
fi

jdkdir=/usr/java/jdk${VERSION}-${BUILD}
jdkbindir=${jdkdir}/bin
mkdir -p ${jdkdir}
curl -# -j -k -L -H "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/${VERSION}-${BUILD}/jdk-${VERSION}-linux-x64.tar.gz | tar xz -C ${jdkdir} --strip-components 1
chown -R root:root ${jdkdir}

echo "installing alternatives (java) for oracle jdk ${VERSION}-${BUILD}"
update-alternatives --install \
	/usr/bin/java java $jdkbindir/java 1${MAJOR_VERSION}0${MINOR_VERSION} \
	--slave /usr/bin/javac javac $jdkbindir/javac \
	--slave /usr/bin/ControlPanel ControlPanel $jdkbindir/ControlPanel \
	--slave /usr/bin/appletviewer appletviewer $jdkbindir/appletviewer \
	--slave /usr/bin/extcheck extcheck $jdkbindir/extcheck \
	--slave /usr/bin/idlj idlj $jdkbindir/idlj \
	--slave /usr/bin/jar jar $jdkbindir/jar \
	--slave /usr/bin/jarsigner jarsigner $jdkbindir/jarsigner \
	--slave /usr/bin/java-rmi.cgi java-rmi.cgi $jdkbindir/java-rmi.cgi \
	--slave /usr/bin/javadoc javadoc $jdkbindir/javadoc \
	--slave /usr/bin/javafxpackager javafxpackager $jdkbindir/javafxpackager \
	--slave /usr/bin/javah javah $jdkbindir/javah \
	--slave /usr/bin/javap javap $jdkbindir/javap \
	--slave /usr/bin/javapackager javapackager $jdkbindir/javapackager \
	--slave /usr/bin/javaws javaws $jdkbindir/javaws \
	--slave /usr/bin/jcmd jcmd $jdkbindir/jcmd \
	--slave /usr/bin/jconsole jconsole $jdkbindir/jconsole \
	--slave /usr/bin/jcontrol jcontrol $jdkbindir/jcontrol \
	--slave /usr/bin/jdb jdb $jdkbindir/jdb \
	--slave /usr/bin/jdeps jdeps $jdkbindir/jdeps \
	--slave /usr/bin/jhat jhat $jdkbindir/jhat \
	--slave /usr/bin/jinfo jinfo $jdkbindir/jinfo \
	--slave /usr/bin/jjs jjs $jdkbindir/jjs \
	--slave /usr/bin/jmap jmap $jdkbindir/jmap \
	--slave /usr/bin/jmc jmc $jdkbindir/jmc \
	--slave /usr/bin/jmc.ini jmc.ini $jdkbindir/jmc.ini \
	--slave /usr/bin/jps jps $jdkbindir/jps \
	--slave /usr/bin/jrunscript jrunscript $jdkbindir/jrunscript \
	--slave /usr/bin/jsadebugd jsadebugd $jdkbindir/jsadebugd \
	--slave /usr/bin/jstack jstack $jdkbindir/jstack \
	--slave /usr/bin/jstat jstat $jdkbindir/jstat \
	--slave /usr/bin/jstatd jstatd $jdkbindir/jstatd \
	--slave /usr/bin/jvisualvm jvisualvm $jdkbindir/jvisualvm \
	--slave /usr/bin/keytool keytool $jdkbindir/keytool \
	--slave /usr/bin/native2ascii native2ascii $jdkbindir/native2ascii \
	--slave /usr/bin/orbd orbd $jdkbindir/orbd \
	--slave /usr/bin/pack200 pack200 $jdkbindir/pack200 \
	--slave /usr/bin/policytool policytool $jdkbindir/policytool \
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

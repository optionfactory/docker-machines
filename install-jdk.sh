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

slaves=""
for el in $(ls $jdkbindir); do
    if [ "$el" != "java" ]; then 
        slaves+="  --slave /usr/bin/${el} ${el} ${jdkbindir}/${el}"
    fi
done

update-alternatives --install /usr/bin/java java "$jdkbindir/java" ${jdkmajorversion} ${slaves}





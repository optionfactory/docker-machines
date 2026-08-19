#!/bin/bash -e
echo "installing jdk (Amazon Corretto)"

if [ ! -f /usr/sbin/update-alternatives ]; then
    ln -s /usr/sbin/update-alternatives  /usr/sbin/alternatives
fi

mkdir -p /usr/java
cp -R /build/amazon-corretto-* /usr/java/
jdkdir=$(readlink -f /usr/java/amazon-corretto-*)
jdkbindir=$(readlink -f ${jdkdir}/bin)
jdkmajorversion=$(basename $jdkdir | sed 's/amazon-corretto-\([0-9]\+\)[.+].*/\1/')

chown -R root:root ${jdkdir}

echo "installing alternatives (java) for Amazon Corretto jdk (${jdkmajorversion})"

slaves=""
for el in $(ls $jdkbindir); do
    if [ "$el" != "java" ]; then 
        slaves+="  --slave /usr/bin/${el} ${el} ${jdkbindir}/${el}"
    fi
done

update-alternatives --install /usr/bin/java java "$jdkbindir/java" ${jdkmajorversion} ${slaves}





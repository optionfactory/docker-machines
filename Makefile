DOCKER_BUILD_OPTIONS=--no-cache=false

JDK8_MINOR_VERSION=102
JDK8_BUILD=b14
TOMCAT8_VERSION=8.5.4
ALFRESCO5_VERSION=201604
ALFRESCO5_BUILD=00007
WILDFLY8_VERSION=8.2.0.Final
LIBERTY10_VERSION=8.5.5.9
DB210_VERSION=v10.5_linuxx64_expc
NEXUS3_VERSION=3.0.1-01
GOSU1_VERSION=1.9

.PHONY: docker-image deps/db210 deps/jdk8 deps/alfresco5 deps/liberty10 deps/nexus3 deps/tomcat8 deps/wildfly8 

docker-images: $(addprefix docker-,$(wildcard optionfactory-*))


#docker-optionfactory-%-jdk8-alfresco5: $(subst -alfresco5,,$@)
docker-optionfactory-centos7-jdk8-alfresco5: docker-optionfactory-centos7-jdk8
docker-optionfactory-debian8-jdk8-alfresco5: docker-optionfactory-debian8-jdk8
docker-optionfactory-opensuse13-jdk8-alfresco5: docker-optionfactory-opensuse13-jdk8	
docker-optionfactory-ubuntu16-jdk8-alfresco5: docker-optionfactory-ubuntu16-jdk8


#docker-optionfactory-%-jdk8-liberty10: $(subst -liberty10,,$@)
docker-optionfactory-centos7-jdk8-liberty10: docker-optionfactory-centos7-jdk8
docker-optionfactory-debian8-jdk8-liberty10: docker-optionfactory-debian8-jdk8
docker-optionfactory-opensuse13-jdk8-liberty10: docker-optionfactory-opensuse13-jdk8	
docker-optionfactory-ubuntu16-jdk8-liberty10: docker-optionfactory-ubuntu16-jdk8


#docker-optionfactory-%-jdk8-nexus3: $(subst -nexus3,,$@)
docker-optionfactory-centos7-jdk8-nexus3: docker-optionfactory-centos7-jdk8
docker-optionfactory-debian8-jdk8-nexus3: docker-optionfactory-debian8-jdk8
docker-optionfactory-opensuse13-jdk8-nexus3: docker-optionfactory-opensuse13-jdk8	
docker-optionfactory-ubuntu16-jdk8-nexus3: docker-optionfactory-ubuntu16-jdk8


#docker-optionfactory-%-jdk8-tomcat8: $(subst -tomcat8,,$@)
docker-optionfactory-centos7-jdk8-tomcat8: docker-optionfactory-centos7-jdk8
docker-optionfactory-debian8-jdk8-tomcat8: docker-optionfactory-debian8-jdk8
docker-optionfactory-opensuse13-jdk8-tomcat8: docker-optionfactory-opensuse13-jdk8	
docker-optionfactory-ubuntu16-jdk8-tomcat8: docker-optionfactory-ubuntu16-jdk8

#docker-optionfactory-%-jdk8-wildfly8: $(subst -wildfly8,,$@)
docker-optionfactory-centos7-jdk8-wildfly8: docker-optionfactory-centos7-jdk8
docker-optionfactory-debian8-jdk8-wildfly8: docker-optionfactory-debian8-jdk8
docker-optionfactory-opensuse13-jdk8-wildfly8: docker-optionfactory-opensuse13-jdk8	
docker-optionfactory-ubuntu16-jdk8-wildfly8: docker-optionfactory-ubuntu16-jdk8


docker-optionfactory-%: docker-image
	@echo building $@
	$(eval name=$(subst docker-optionfactory-,,$@))
	docker build ${DOCKER_BUILD_OPTIONS} --tag=optionfactory/$(name):0.1 optionfactory-$(name)
	docker tag optionfactory/$(name):0.1 optionfactory/$(name):latest

docker-image: deps/db210 deps/jdk8 deps/alfresco5 deps/liberty10 deps/nexus3 deps/spawn-and-tail deps/tomcat8 deps/wildfly8 deps/gosu1
	@echo "syncing jdk 8"
	@echo optionfactory-*-jdk8/deps | xargs -n 1 rsync -az install-jdk.sh
	@echo optionfactory-*-jdk8/deps | xargs -n 1 rsync -az deps/jdk*
	@echo "syncing tomcat 8"
	@echo optionfactory-*-tomcat8/deps | xargs -n 1 rsync -az install-tomcat.sh
	@echo optionfactory-*-tomcat8/deps | xargs -n 1 rsync -az init-tomcat.sh
	@echo optionfactory-*-tomcat8/deps | xargs -n 1 rsync -az deps/apache-tomcat*
	@echo "syncing wildfly 8"
	@echo optionfactory-*-wildfly8/deps | xargs -n 1 rsync -az install-wildfly.sh
	@echo optionfactory-*-wildfly8/deps | xargs -n 1 rsync -az init-wildfly.sh
	@echo optionfactory-*-wildfly8/deps | xargs -n 1 rsync -az deps/wildfly-*
	@echo "syncing ps1"
	@echo optionfactory-*-jdk8/deps optionfactory-*-db210/deps optionfactory-*-mariadb10/deps | xargs -n 1 rsync -az install-ps1.sh
	@echo "syncing spawn-and-tail"
	@echo optionfactory-*-jdk8/deps optionfactory-*-db210/deps optionfactory-*-mariadb10/deps | xargs -n 1 rsync -az install-spawn-and-tail.sh
	@echo optionfactory-*-jdk8/deps optionfactory-*-db210/deps optionfactory-*-mariadb10/deps | xargs -n 1 rsync -az deps/spawn-and-tail
	@echo "syncing alfresco 5"
	@echo optionfactory-*-alfresco5/deps | xargs -n 1 rsync -az install-alfresco.sh
	@echo optionfactory-*-alfresco5/deps | xargs -n 1 rsync -az init-alfresco.sh
	@echo optionfactory-*-alfresco5/deps | xargs -n 1 rsync -az deps/alfresco*
	@echo "syncing liberty 10"
	@echo optionfactory-*-liberty10/deps | xargs -n 1 rsync -az install-liberty.sh
	@echo optionfactory-*-liberty10/deps | xargs -n 1 rsync -az init-liberty.sh
	@echo optionfactory-*-liberty10/deps | xargs -n 1 rsync -az deps/liberty*
	@echo "syncing db2 10"
	@echo optionfactory-*-db210/deps | xargs -n 1 rsync -az install-db2.sh
	@echo optionfactory-*-db210/deps | xargs -n 1 rsync -az init-db2.sh
	@echo optionfactory-*-db210/deps | xargs -n 1 rsync -az deps/db2-*
	@echo "syncing nexus 3"
	@echo optionfactory-*-nexus3/deps | xargs -n 1 rsync -az install-nexus.sh
	@echo optionfactory-*-nexus3/deps | xargs -n 1 rsync -az init-nexus.sh
	@echo optionfactory-*-nexus3/deps | xargs -n 1 rsync -az deps/nexus-*
	@echo "syncing mariadb 10"
	@echo optionfactory-*-mariadb10/deps | xargs -n 1 rsync -az install-mariadb.sh
	@echo optionfactory-*-mariadb10/deps | xargs -n 1 rsync -az init-mariadb.sh
	@echo optionfactory-*-nexus3/deps | xargs -n 1 rsync -az deps/nexus-*
	@echo "syncing postgres 9"
	@echo optionfactory-*-postgres9/deps | xargs -n 1 rsync -az install-postgres.sh
	@echo optionfactory-*-postgres9/deps | xargs -n 1 rsync -az init-postgres.sh	
	@echo "syncing gosu"
	@echo optionfactory-*-postgres9/deps optionfactory-*-alfresco5/deps | xargs -n 1 rsync -az deps/gosu-*


deps/db210: deps/db2-${DB210_VERSION}
deps/jdk8: deps/jdk1.8.0_${JDK8_MINOR_VERSION}
deps/alfresco5: deps/alfresco-${ALFRESCO5_VERSION}/alfresco-installer.bin
deps/liberty10: deps/liberty-${LIBERTY10_VERSION}
deps/nexus3: deps/nexus-${NEXUS3_VERSION}
deps/tomcat8: deps/apache-tomcat-${TOMCAT8_VERSION}
deps/wildfly8: deps/wildfly-${WILDFLY8_VERSION}
deps/gosu1: deps/gosu-${GOSU1_VERSION}


deps/jdk1.8.0_${JDK8_MINOR_VERSION}:
	curl -# -j -k -L -H "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u${JDK8_MINOR_VERSION}-${JDK8_BUILD}/jdk-8u${JDK8_MINOR_VERSION}-linux-x64.tar.gz | tar xz -C deps 
deps/apache-tomcat-${TOMCAT8_VERSION}:
	curl -# -sSL -k https://archive.apache.org/dist/tomcat/tomcat-8/v${TOMCAT8_VERSION}/bin/apache-tomcat-${TOMCAT8_VERSION}.tar.gz | tar xz -C deps
deps/alfresco-${ALFRESCO5_VERSION}/alfresco-installer.bin:
	curl http://dl.alfresco.com/release/community/${ALFRESCO5_VERSION}-build-${ALFRESCO5_BUILD}/alfresco-community-installer-${ALFRESCO5_VERSION}-linux-x64.bin -o deps/alfresco-${ALFRESCO5_VERSION}/alfresco-installer.bin
deps/wildfly-${WILDFLY8_VERSION}:
	curl http://download.jboss.org/wildfly/${WILDFLY8_VERSION}/wildfly-${WILDFLY8_VERSION}.tar.gz | tar xz -C deps
deps/db2-${DB210_VERSION}:
	echo "you must manually download this file"
	echo "mkdir -p deps/db2-${DB210_VERSION}"
	echo "curl {url} | tar xz -C deps/db2-${DB210_VERSION} --strip-component 1"
	exit 1

deps/liberty-${LIBERTY10_VERSION}:
	wget --no-check-certificate "https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/wasdev/downloads/wlp/${LIBERTY10_VERSION}/wlp-javaee7-${LIBERTY10_VERSION}.zip"
	cd deps && unzip ../wlp-javaee7-${LIBERTY10_VERSION}.zip && cd ..
	mv deps/wlp deps/liberty-${LIBERTY10_VERSION}
	rm -rf wlp-javaee7-${LIBERTY10_VERSION}.zip

deps/nexus-${NEXUS3_VERSION}:
	curl -# -sSL -k https://sonatype-download.global.ssl.fastly.net/nexus/3/nexus-${NEXUS3_VERSION}-unix.tar.gz | tar xz -C deps

deps/gosu-${GOSU1_VERSION}:
	curl -# -sSL -k https://github.com/tianon/gosu/releases/download/1.9/gosu-amd64 -o deps/gosu-${GOSU1_VERSION}
	chmod +x deps/gosu-${GOSU1_VERSION}

deps/spawn-and-tail:
	curl -# -j -k -L  https://github.com/optionfactory/spawn-and-tail/releases/download/v0.2/spawn-and-tail-linux-amd64 > deps/spawn-and-tail

clean:
	rm -rf optionfactory-*/install-*.sh
	rm -rf optionfactory-*/deps/*

clean-deps:
	rm -rf deps/*
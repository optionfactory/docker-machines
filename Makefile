DOCKER_BUILD_OPTIONS=--no-cache=false
TAG_VERSION=0.5

#software versions
JDK8_MINOR_VERSION=172
JDK8_BUILD=b11
JDK8_UID=a58eab1ec242421181065cdc37240b08

TOMCAT8_VERSION=8.5.31

ALFRESCO5_VERSION=201707
ALFRESCO5_BUILD=00028

WILDFLY8_VERSION=8.2.0.Final

NEXUS3_VERSION=3.0.1-01

GOSU1_VERSION=1.9

SPAWN_AND_TAIL_VERSION=0.2

KAFKA1_VERSION=1.1.0
KAFKA1_SCALA_VERSION=2.11

ZOOKEEPER3_VERSION=3.4.12

#/software versions

help:
	@echo make [clean-deps] [clean] sync docker-images
	exit 1

docker-images: $(addprefix docker-,$(wildcard optionfactory-*))



#docker-optionfactory-%-jdk8: $(subst -jdk8,,$@)
docker-optionfactory-centos7-jdk8: docker-optionfactory-centos7
docker-optionfactory-debian9-jdk8: docker-optionfactory-debian9
docker-optionfactory-opensuse15-jdk8: docker-optionfactory-opensuse15
docker-optionfactory-ubuntu18-jdk8: docker-optionfactory-ubuntu18

#docker-optionfactory-%-mariadb10: $(subst -mariadb10,,$@)
docker-optionfactory-centos7-mariadb10: docker-optionfactory-centos7
docker-optionfactory-debian9-mariadb10: docker-optionfactory-debian9
docker-optionfactory-opensuse15-mariadb10: docker-optionfactory-opensuse15
docker-optionfactory-ubuntu18-mariadb10: docker-optionfactory-ubuntu18

#docker-optionfactory-%-postgres9: $(subst -postgres9,,$@)
docker-optionfactory-centos7-postgres9: docker-optionfactory-centos7
docker-optionfactory-debian9-postgres9: docker-optionfactory-debian9
docker-optionfactory-opensuse15-postgres9: docker-optionfactory-opensuse15
docker-optionfactory-ubuntu18-postgres9: docker-optionfactory-ubuntu18

#docker-optionfactory-%-kafka1: $(subst -kafka1,,$@)
docker-optionfactory-centos7-jdk8-kafka1: docker-optionfactory-centos7-jdk8
docker-optionfactory-debian9-jdk8-kafka1: docker-optionfactory-debian9-jdk8
docker-optionfactory-opensuse15-jdk8-kafka1: docker-optionfactory-opensuse15-jdk8
docker-optionfactory-ubuntu18-jdk8-kafka1: docker-optionfactory-ubuntu18-jdk8

#docker-optionfactory-%-zookeeper3: $(subst -zookeeper3,,$@)
docker-optionfactory-centos7-jdk8-zookeeper3: docker-optionfactory-centos7-jdk8
docker-optionfactory-debian9-jdk8-zookeeper3: docker-optionfactory-debian9-jdk8
docker-optionfactory-opensuse15-jdk8-zookeeper3: docker-optionfactory-opensuse15-jdk8
docker-optionfactory-ubuntu18-jdk8-zookeeper3: docker-optionfactory-ubuntu18-jdk8

#docker-optionfactory-%-jdk8-alfresco5: $(subst -alfresco5,,$@)
docker-optionfactory-centos7-jdk8-alfresco5: docker-optionfactory-centos7-jdk8
docker-optionfactory-debian9-jdk8-alfresco5: docker-optionfactory-debian9-jdk8
docker-optionfactory-opensuse15-jdk8-alfresco5: docker-optionfactory-opensuse15-jdk8
docker-optionfactory-ubuntu18-jdk8-alfresco5: docker-optionfactory-ubuntu18-jdk8

#docker-optionfactory-%-jdk8-nexus3: $(subst -nexus3,,$@)
docker-optionfactory-centos7-jdk8-nexus3: docker-optionfactory-centos7-jdk8
docker-optionfactory-debian9-jdk8-nexus3: docker-optionfactory-debian9-jdk8
docker-optionfactory-opensuse15-jdk8-nexus3: docker-optionfactory-opensuse15-jdk8
docker-optionfactory-ubuntu18-jdk8-nexus3: docker-optionfactory-ubuntu18-jdk8

#docker-optionfactory-%-jdk8-tomcat8: $(subst -tomcat8,,$@)
docker-optionfactory-centos7-jdk8-tomcat8: docker-optionfactory-centos7-jdk8
docker-optionfactory-debian9-jdk8-tomcat8: docker-optionfactory-debian9-jdk8
docker-optionfactory-opensuse15-jdk8-tomcat8: docker-optionfactory-opensuse15-jdk8
docker-optionfactory-ubuntu18-jdk8-tomcat8: docker-optionfactory-ubuntu18-jdk8

#docker-optionfactory-%-jdk8-wildfly8: $(subst -wildfly8,,$@)
docker-optionfactory-centos7-jdk8-wildfly8: docker-optionfactory-centos7-jdk8
docker-optionfactory-debian9-jdk8-wildfly8: docker-optionfactory-debian9-jdk8
docker-optionfactory-opensuse15-jdk8-wildfly8: docker-optionfactory-opensuse15-jdk8
docker-optionfactory-ubuntu18-jdk8-wildfly8: docker-optionfactory-ubuntu18-jdk8

docker-optionfactory-%:
	@echo building $@
	$(eval name=$(subst docker-optionfactory-,,$@))
	docker build ${DOCKER_BUILD_OPTIONS} --tag=optionfactory/$(name):${TAG_VERSION} optionfactory-$(name)
	docker tag optionfactory/$(name):${TAG_VERSION} optionfactory/$(name):latest

sync: deps
	@echo "syncing gosu"
	@echo optionfactory-centos7/deps optionfactory-debian9/deps optionfactory-opensuse15/deps optionfactory-ubuntu18/deps | xargs -n 1 rsync -az deps/gosu-${GOSU1_VERSION}
	@echo "syncing ps1"
	@echo optionfactory-centos7/deps optionfactory-debian9/deps optionfactory-opensuse15/deps optionfactory-ubuntu18/deps | xargs -n 1 rsync -az install-ps1.sh
	@echo "syncing spawn-and-tail"
	@echo optionfactory-centos7/deps optionfactory-debian9/deps optionfactory-opensuse15/deps optionfactory-ubuntu18/deps | xargs -n 1 rsync -az install-spawn-and-tail.sh
	@echo optionfactory-centos7/deps optionfactory-debian9/deps optionfactory-opensuse15/deps optionfactory-ubuntu18/deps | xargs -n 1 rsync -az deps/spawn-and-tail-${SPAWN_AND_TAIL_VERSION}
	@echo "syncing jdk 8"
	@echo optionfactory-*-jdk8/deps | xargs -n 1 rsync -az install-jdk.sh
	@echo optionfactory-*-jdk8/deps | xargs -n 1 rsync -az deps/jdk1.8.0_${JDK8_MINOR_VERSION}
	@echo "syncing tomcat 8"
	@echo optionfactory-*-tomcat8/deps | xargs -n 1 rsync -az install-tomcat.sh
	@echo optionfactory-*-tomcat8/deps | xargs -n 1 rsync -az init-tomcat.sh
	@echo optionfactory-*-tomcat8/deps | xargs -n 1 rsync -az deps/apache-tomcat-${TOMCAT8_VERSION}
	@echo "syncing wildfly 8"
	@echo optionfactory-*-wildfly8/deps | xargs -n 1 rsync -az install-wildfly.sh
	@echo optionfactory-*-wildfly8/deps | xargs -n 1 rsync -az init-wildfly.sh
	@echo optionfactory-*-wildfly8/deps | xargs -n 1 rsync -az deps/wildfly-${WILDFLY8_VERSION}
	@echo "syncing alfresco 5"
	@echo optionfactory-*-alfresco5/deps | xargs -n 1 rsync -az install-alfresco.sh
	@echo optionfactory-*-alfresco5/deps | xargs -n 1 rsync -az init-alfresco.sh
	@echo optionfactory-*-alfresco5/deps | xargs -n 1 rsync -az deps/alfresco-${ALFRESCO5_VERSION}
	@echo "syncing nexus 3"
	@echo optionfactory-*-nexus3/deps | xargs -n 1 rsync -az install-nexus.sh
	@echo optionfactory-*-nexus3/deps | xargs -n 1 rsync -az init-nexus.sh
	@echo optionfactory-*-nexus3/deps | xargs -n 1 rsync -az deps/nexus-${NEXUS3_VERSION}
	@echo "syncing mariadb 10"
	@echo optionfactory-*-mariadb10/deps | xargs -n 1 rsync -az install-mariadb.sh
	@echo optionfactory-*-mariadb10/deps | xargs -n 1 rsync -az init-mariadb.sh
	@echo "syncing postgres 9"
	@echo optionfactory-*-postgres9/deps | xargs -n 1 rsync -az install-postgres.sh
	@echo optionfactory-*-postgres9/deps | xargs -n 1 rsync -az init-postgres.sh
	@echo "syncing kafka1"
	@echo optionfactory-*-kafka1/deps optionfactory-*-kafka1-zookeeper3-standalone/deps | xargs -n 1 rsync -az install-kafka.sh
	@echo optionfactory-*-kafka1/deps | xargs -n 1 rsync -az init-kafka.sh
	@echo optionfactory-*-kafka1/deps optionfactory-*-kafka1-zookeeper3-standalone/deps | xargs -n 1 rsync -az deps/kafka_${KAFKA1_SCALA_VERSION}-${KAFKA1_VERSION}
	@echo "syncing zookeeper3"
	@echo optionfactory-*-zookeeper3/deps optionfactory-*-kafka1-zookeeper3-standalone/deps | xargs -n 1 rsync -az install-zookeeper.sh
	@echo optionfactory-*-zookeeper3/deps | xargs -n 1 rsync -az init-zookeeper.sh
	@echo optionfactory-*-zookeeper3/deps optionfactory-*-kafka1-zookeeper3-standalone/deps | xargs -n 1 rsync -az deps/zookeeper-${ZOOKEEPER3_VERSION}
	@echo "syncing kafka1-zookeeper3-standalone"
	@echo optionfactory-*-kafka1-zookeeper3-standalone/deps | xargs -n 1 rsync -az install-kafka-zookeeper-standalone.sh
	@echo optionfactory-*-kafka1-zookeeper3-standalone/deps | xargs -n 1 rsync -az init-kafka-zookeeper-standalone.sh

deps: deps/jdk8 deps/tomcat8 deps/alfresco5 deps/wildfly8 deps/nexus3 deps/gosu1 deps/spawn-and-tail1 deps/kafka1 deps/zookeeper3

deps/jdk8: deps/jdk1.8.0_${JDK8_MINOR_VERSION}
deps/tomcat8: deps/apache-tomcat-${TOMCAT8_VERSION}
deps/alfresco5: deps/alfresco-${ALFRESCO5_VERSION}/alfresco-installer.bin
deps/wildfly8: deps/wildfly-${WILDFLY8_VERSION}
deps/nexus3: deps/nexus-${NEXUS3_VERSION}
deps/gosu1: deps/gosu-${GOSU1_VERSION}
deps/spawn-and-tail1: deps/spawn-and-tail-${SPAWN_AND_TAIL_VERSION}
deps/kafka1: deps/kafka_${KAFKA1_SCALA_VERSION}-${KAFKA1_VERSION}
deps/zookeeper3: deps/zookeeper-${ZOOKEEPER3_VERSION}


deps/jdk1.8.0_${JDK8_MINOR_VERSION}:
	curl -# -j -k -L -H "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u${JDK8_MINOR_VERSION}-${JDK8_BUILD}/${JDK8_UID}/jdk-8u${JDK8_MINOR_VERSION}-linux-x64.tar.gz | tar xz -C deps
deps/apache-tomcat-${TOMCAT8_VERSION}:
	curl -# -sSL -k https://archive.apache.org/dist/tomcat/tomcat-8/v${TOMCAT8_VERSION}/bin/apache-tomcat-${TOMCAT8_VERSION}.tar.gz | tar xz -C deps
deps/alfresco-${ALFRESCO5_VERSION}/alfresco-installer.bin:
	mkdir -p deps/alfresco-${ALFRESCO5_VERSION}
	curl -# -j -k -L http://dl.alfresco.com/release/community/${ALFRESCO5_VERSION}-build-${ALFRESCO5_BUILD}/alfresco-community-installer-${ALFRESCO5_VERSION}-linux-x64.bin -o deps/alfresco-${ALFRESCO5_VERSION}/alfresco-installer.bin
deps/wildfly-${WILDFLY8_VERSION}:
	curl -# -j -k -L http://download.jboss.org/wildfly/${WILDFLY8_VERSION}/wildfly-${WILDFLY8_VERSION}.tar.gz | tar xz -C deps
deps/nexus-${NEXUS3_VERSION}:
	curl -# -sSL -k https://sonatype-download.global.ssl.fastly.net/nexus/3/nexus-${NEXUS3_VERSION}-unix.tar.gz | tar xz -C deps
deps/gosu-${GOSU1_VERSION}:
	curl -# -sSL -k https://github.com/tianon/gosu/releases/download/1.9/gosu-amd64 -o deps/gosu-${GOSU1_VERSION}
	chmod +x deps/gosu-${GOSU1_VERSION}
deps/spawn-and-tail-${SPAWN_AND_TAIL_VERSION}:
	curl -# -j -k -L https://github.com/optionfactory/spawn-and-tail/releases/download/v${SPAWN_AND_TAIL_VERSION}/spawn-and-tail-linux-amd64 > deps/spawn-and-tail-${SPAWN_AND_TAIL_VERSION}
	chmod +x deps/spawn-and-tail-${SPAWN_AND_TAIL_VERSION}
deps/kafka_${KAFKA1_SCALA_VERSION}-${KAFKA1_VERSION}:
	curl -# -j -k -L http://apache.mirrors.spacedump.net/kafka/${KAFKA1_VERSION}/kafka_${KAFKA1_SCALA_VERSION}-${KAFKA1_VERSION}.tgz | tar xz -C deps
deps/zookeeper-${ZOOKEEPER3_VERSION}:
	curl -# -j -k -L http://mirror.nohup.it/apache/zookeeper/zookeeper-${ZOOKEEPER3_VERSION}/zookeeper-${ZOOKEEPER3_VERSION}.tar.gz | tar xz -C deps




clean: FORCE
	rm -rf optionfactory-*/install-*.sh
	rm -rf optionfactory-*/deps/*

clean-deps: FORCE
	rm -rf deps/*

cleanup-docker-images:
	docker images --quiet --filter=dangling=true | xargs --no-run-if-empty docker rmi
	docker volume prune

#If a rule has no prerequisites or recipe, and the target of the rule is a nonexistent file,
#then make imagines this target to have been updated whenever its rule is run.
#This implies that all targets depending on this one will always have their recipe run.
FORCE:
.PHONY: sync deps docker-images clean clean-deps

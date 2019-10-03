#we user squash here to remove unwanted layers, which is an experimental feature
#{"experimental": true} > /etc/docker/daemon.json
DOCKER_BUILD_OPTIONS=--no-cache=false --squash
TAG_VERSION=3

#software versions
JDK11_VERSION=11.0.4
JDK11_BUILD=11
TOMCAT9_VERSION=9.0.26
GOSU1_VERSION=1.11
SPAWN_AND_TAIL_VERSION=0.2
GOLANG1_VERSION=1.13.1
ETCD3_VERSION=3.4.1
#/software versions

help:
	@echo usage: make [clean-deps] [clean] sync docker-images
	@echo usage: make [clean-deps] [clean] docker-optionfactory-centos8-mariadb10
	exit 1

docker-images: $(addprefix docker-,$(wildcard optionfactory-*))


docker-optionfactory-centos7: sync-tools
docker-optionfactory-centos8: sync-tools
docker-optionfactory-debian10: sync-tools
docker-optionfactory-ubuntu18: sync-tools

#docker-optionfactory-%-jdk11: $(subst -jdk11,,$@)
docker-optionfactory-centos7-jdk11: sync-jdk11 docker-optionfactory-centos7
docker-optionfactory-centos8-jdk11: sync-jdk11 docker-optionfactory-centos8
docker-optionfactory-debian10-jdk11: sync-jdk11 docker-optionfactory-debian10
docker-optionfactory-ubuntu18-jdk11: sync-jdk11 docker-optionfactory-ubuntu18


#docker-optionfactory-%-mariadb10: $(subst -mariadb10,,$@)
docker-optionfactory-centos7-mariadb10: sync-mariadb10 docker-optionfactory-centos7
docker-optionfactory-centos8-mariadb10: sync-mariadb10 docker-optionfactory-centos8
docker-optionfactory-debian10-mariadb10: sync-mariadb10 docker-optionfactory-debian10
docker-optionfactory-ubuntu18-mariadb10: sync-mariadb10 docker-optionfactory-ubuntu18

#docker-optionfactory-%-postgres11: $(subst -postgres11,,$@)
docker-optionfactory-centos7-postgres11: sync-postgres11 docker-optionfactory-centos7
docker-optionfactory-centos8-postgres11: sync-postgres11 docker-optionfactory-centos8
docker-optionfactory-debian10-postgres11: sync-postgres11 docker-optionfactory-debian10
docker-optionfactory-ubuntu18-postgres11: sync-postgres11 docker-optionfactory-ubuntu18

#docker-optionfactory-%-golang1: $(subst -golang1,,$@)
docker-optionfactory-centos7-golang1: sync-golang1 docker-optionfactory-centos7
docker-optionfactory-centos8-golang1: sync-golang1 docker-optionfactory-centos8
docker-optionfactory-debian10-golang1: sync-golang1 docker-optionfactory-debian10
docker-optionfactory-ubuntu18-golang1: sync-golang1 docker-optionfactory-ubuntu18

#docker-optionfactory-%-etcd3: $(subst -etcd3,,$@)
docker-optionfactory-centos7-etcd3: sync-etcd3 docker-optionfactory-centos7
docker-optionfactory-centos8-etcd3: sync-etcd3 docker-optionfactory-centos8
docker-optionfactory-debian9-etcd3: sync-etcd3 docker-optionfactory-debian9
docker-optionfactory-ubuntu18-etcd3: sync-etcd3 docker-optionfactory-ubuntu18


#docker-optionfactory-%-jdk11-tomcat9: $(subst -tomcat9,,$@)
docker-optionfactory-centos7-jdk11-tomcat9: sync-tomcat9 docker-optionfactory-centos7-jdk11
docker-optionfactory-centos8-jdk11-tomcat9: sync-tomcat9 docker-optionfactory-centos8-jdk11
docker-optionfactory-debian10-jdk11-tomcat9: sync-tomcat9 docker-optionfactory-debian10-jdk11
docker-optionfactory-ubuntu18-jdk11-tomcat9: sync-tomcat9 docker-optionfactory-ubuntu18-jdk11

docker-optionfactory-%:
	@echo building $@
	$(eval name=$(subst docker-optionfactory-,,$@))
	docker build ${DOCKER_BUILD_OPTIONS} --tag=optionfactory/$(name):${TAG_VERSION} optionfactory-$(name)
	docker tag optionfactory/$(name):${TAG_VERSION} optionfactory/$(name):latest



sync: sync-tools sync-jdk11 sync-tomcat9 sync-mariadb10 sync-postgres11 sync-golang1

sync-tools: deps/gosu1 deps/spawn-and-tail1
	@echo "syncing gosu"
	@echo optionfactory-centos7/deps optionfactory-centos8/deps optionfactory-debian10/deps optionfactory-ubuntu18/deps | xargs -n 1 rsync -az deps/gosu-${GOSU1_VERSION}
	@echo "syncing ps1"
	@echo optionfactory-centos7/deps optionfactory-centos8/deps optionfactory-debian10/deps optionfactory-ubuntu18/deps | xargs -n 1 rsync -az install-ps1.sh
	@echo "syncing spawn-and-tail"
	@echo optionfactory-centos7/deps optionfactory-centos8/deps optionfactory-debian10/deps optionfactory-ubuntu18/deps | xargs -n 1 rsync -az install-spawn-and-tail.sh
	@echo optionfactory-centos7/deps optionfactory-centos8/deps optionfactory-debian10/deps optionfactory-ubuntu18/deps | xargs -n 1 rsync -az deps/spawn-and-tail-${SPAWN_AND_TAIL_VERSION}
sync-jdk11: deps/jdk11
	@echo "syncing jdk 11"
	@echo optionfactory-*-jdk11/deps | xargs -n 1 rsync -az install-jdk11.sh
	@echo optionfactory-*-jdk11/deps | xargs -n 1 rsync -az deps/jdk-${JDK11_VERSION}+${JDK11_BUILD}

sync-tomcat9: deps/tomcat9
	@echo "syncing tomcat 8"
	@echo optionfactory-*-tomcat9/deps | xargs -n 1 rsync -az install-tomcat9.sh
	@echo optionfactory-*-tomcat9/deps | xargs -n 1 rsync -az init-tomcat9.sh
	@echo optionfactory-*-tomcat9/deps | xargs -n 1 rsync -az deps/apache-tomcat-${TOMCAT9_VERSION}
sync-mariadb10: deps/mariadb10
	@echo "syncing mariadb 10"
	@echo optionfactory-*-mariadb10/deps | xargs -n 1 rsync -az install-mariadb10.sh
	@echo optionfactory-*-mariadb10/deps | xargs -n 1 rsync -az init-mariadb10.sh
sync-postgres11: deps/postgres11
	@echo "syncing postgres 11"
	@echo optionfactory-*-postgres11/deps | xargs -n 1 rsync -az install-postgres11.sh
	@echo optionfactory-*-postgres11/deps | xargs -n 1 rsync -az init-postgres11.sh
sync-etcd3: deps/etcd3
	@echo "syncing etcd3"
	@echo optionfactory-*-etcd3/deps | xargs -n 1 rsync -az install-etcd3.sh
	@echo optionfactory-*-etcd3/deps | xargs -n 1 rsync -az init-etcd3.sh
	@echo optionfactory-*-etcd3/deps | xargs -n 1 rsync -az deps/etcd-v${ETCD3_VERSION}-linux-amd64
sync-golang1: deps/golang1
	@echo "syncing golang"
	@echo optionfactory-*-golang1/deps | xargs -n 1 rsync -az install-golang1.sh
	@echo optionfactory-*-golang1/deps | xargs -n 1 rsync -az init-golang1.sh
	@echo optionfactory-*-golang1/deps | xargs -n 1 rsync -az golang1-project-makefile.tpl
	@echo optionfactory-*-golang1 | sed -r 's/optionfactory-(\w+)-golang1/\1\n/g' | xargs -n 1 -I% sed -i "s/{{DISTRO}}/%/g" optionfactory-%-golang1/deps/golang1-project-makefile.tpl
	@echo optionfactory-*-golang1/deps | xargs -n 1 rsync -az deps/golang-${GOLANG1_VERSION}


deps: deps/gosu1 deps/spawn-and-tail1 deps/jdk11 deps/tomcat9 deps/mariadb10 deps/postgres11 deps/golang1

deps/gosu1: deps/gosu-${GOSU1_VERSION}
deps/spawn-and-tail1: deps/spawn-and-tail-${SPAWN_AND_TAIL_VERSION}
deps/jdk11: deps/jdk-${JDK11_VERSION}+${JDK11_BUILD}
deps/tomcat9: deps/apache-tomcat-${TOMCAT9_VERSION}
deps/mariadb10:
deps/postgres11:
deps/golang1: deps/golang-${GOLANG1_VERSION}/bin/go
deps/etcd3: deps/etcd-v${ETCD3_VERSION}-linux-amd64

deps/jdk-${JDK11_VERSION}+${JDK11_BUILD}:
	curl -# -j -k -L https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-${JDK11_VERSION}%2B${JDK11_BUILD}/OpenJDK11U-jdk_x64_linux_hotspot_${JDK11_VERSION}_${JDK11_BUILD}.tar.gz | tar xz -C deps
deps/apache-tomcat-${TOMCAT9_VERSION}:
	curl -# -sSL -k https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT9_VERSION}/bin/apache-tomcat-${TOMCAT9_VERSION}.tar.gz | tar xz -C deps
deps/gosu-${GOSU1_VERSION}:
	curl -# -sSL -k https://github.com/tianon/gosu/releases/download/${GOSU1_VERSION}/gosu-amd64 -o deps/gosu-${GOSU1_VERSION}
	chmod +x deps/gosu-${GOSU1_VERSION}
deps/spawn-and-tail-${SPAWN_AND_TAIL_VERSION}:
	curl -# -j -k -L https://github.com/optionfactory/spawn-and-tail/releases/download/v${SPAWN_AND_TAIL_VERSION}/spawn-and-tail-linux-amd64 > deps/spawn-and-tail-${SPAWN_AND_TAIL_VERSION}
	chmod +x deps/spawn-and-tail-${SPAWN_AND_TAIL_VERSION}
deps/golang-${GOLANG1_VERSION}/bin/go:
	mkdir -p deps/golang-${GOLANG1_VERSION}
	curl -# -j -k -L https://golang.org/dl/go${GOLANG1_VERSION}.linux-amd64.tar.gz | tar xz -C deps/golang-${GOLANG1_VERSION} --strip-components=1
deps/etcd-v${ETCD3_VERSION}-linux-amd64:
	curl -# -j -k -L  https://github.com/coreos/etcd/releases/download/v${ETCD3_VERSION}/etcd-v${ETCD3_VERSION}-linux-amd64.tar.gz | tar xz -C deps

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

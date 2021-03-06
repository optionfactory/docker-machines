#we user squash here to remove unwanted layers, which is an experimental feature
#{"experimental": true} > /etc/docker/daemon.json
DOCKER_BUILD_OPTIONS=--no-cache=false --squash
TAG_VERSION=11

#software versions
JDK11_VERSION=11.0.11
JDK11_BUILD=9
TOMCAT9_VERSION=9.0.48
TOMCAT9_ERROR_REPORT_VALVE_VERSION=2.0
GOSU1_VERSION=1.12
SPAWN_AND_TAIL_VERSION=0.2
GOLANG1_VERSION=1.16.5
ETCD3_VERSION=3.5.0
KEYCLOAK12_VERSION=12.0.4
KEYCLOAK14_VERSION=14.0.0
PSQL_JDBC_VERSION=42.2.22
MAVEN3_VERSION=3.8.1
#/software versions

help:
	@echo usage: make [clean-deps] [clean] sync docker-images
	@echo usage: make [clean-deps] [clean] docker-optionfactory-centos8-mariadb10
	exit 1

docker-images: $(addprefix docker-,$(wildcard optionfactory-*))

docker-push:
	@echo pushing tag: ${TAG_VERSION}
	@docker images --filter="reference=optionfactory/*:${TAG_VERSION}" --format='{{.Repository}}' | sort | uniq |  xargs -I'{}' docker push {}:${TAG_VERSION}
	@echo pushing tag: latest
	@docker images --filter="reference=optionfactory/*:${TAG_VERSION}" --format='{{.Repository}}' | sort | uniq |  xargs -I'{}' docker push {}:latest


docker-optionfactory-centos8: sync-tools
docker-optionfactory-debian10: sync-tools
docker-optionfactory-ubuntu20: sync-tools
docker-optionfactory-rocky8: sync-tools

#docker-optionfactory-%-jdk11: $(subst -jdk11,,$@)
docker-optionfactory-centos8-jdk11: sync-jdk11 docker-optionfactory-centos8
docker-optionfactory-centos8-jdk11: sync-jdk11 docker-optionfactory-centos8
docker-optionfactory-debian10-jdk11: sync-jdk11 docker-optionfactory-debian10
docker-optionfactory-ubuntu20-jdk11: sync-jdk11 docker-optionfactory-ubuntu20
docker-optionfactory-rocky8-jdk11: sync-jdk11 docker-optionfactory-rocky8

#docker-optionfactory-%-jdk11-builder: $(subst -jdk11-builder,,$@)
docker-optionfactory-centos8-jdk11-builder: sync-builder docker-optionfactory-centos8-jdk11
docker-optionfactory-debian10-jdk11-builder: sync-builder docker-optionfactory-debian10-jdk11
docker-optionfactory-ubuntu20-jdk11-builder: sync-builder docker-optionfactory-ubuntu20-jdk11
docker-optionfactory-rocky8-jdk11-builder: sync-builder docker-optionfactory-rocky8-jdk11

#docker-optionfactory-%-nginx120: $(subst -nginx120,,$@)
docker-optionfactory-centos8-nginx120: sync-nginx120 docker-optionfactory-centos8
docker-optionfactory-debian10-nginx120: sync-nginx120 docker-optionfactory-debian10
docker-optionfactory-ubuntu20-nginx120: sync-nginx120 docker-optionfactory-ubuntu20
docker-optionfactory-rocky8-nginx120: sync-nginx120 docker-optionfactory-rocky8

#docker-optionfactory-%-mariadb10: $(subst -mariadb10,,$@)
docker-optionfactory-centos8-mariadb10: sync-mariadb10 docker-optionfactory-centos8
docker-optionfactory-debian10-mariadb10: sync-mariadb10 docker-optionfactory-debian10
docker-optionfactory-ubuntu20-mariadb10: sync-mariadb10 docker-optionfactory-ubuntu20
docker-optionfactory-rocky8-mariadb10: sync-mariadb10 docker-optionfactory-rocky8

#docker-optionfactory-%-postgres12: $(subst -postgres12,,$@)
docker-optionfactory-centos8-postgres12: sync-postgres12 docker-optionfactory-centos8
docker-optionfactory-debian10-postgres12: sync-postgres12 docker-optionfactory-debian10
docker-optionfactory-ubuntu20-postgres12: sync-postgres12 docker-optionfactory-ubuntu20
docker-optionfactory-rocky8-postgres12: sync-postgres12 docker-optionfactory-rocky8

#docker-optionfactory-%-barman2: $(subst -postgres12,,$@)
docker-optionfactory-centos8-barman2: sync-barman2 docker-optionfactory-centos8
docker-optionfactory-debian10-barman2: sync-barman2 docker-optionfactory-debian10
docker-optionfactory-ubuntu20-barman2: sync-barman2 docker-optionfactory-ubuntu20
docker-optionfactory-rocky8-barman2: sync-barman2 docker-optionfactory-rocky8


#docker-optionfactory-%-golang1: $(subst -golang1,,$@)
docker-optionfactory-centos8-golang1: sync-golang1 docker-optionfactory-centos8
docker-optionfactory-debian10-golang1: sync-golang1 docker-optionfactory-debian10
docker-optionfactory-ubuntu20-golang1: sync-golang1 docker-optionfactory-ubuntu20
docker-optionfactory-rocky8-golang1: sync-golang1 docker-optionfactory-rocky8

#docker-optionfactory-%-etcd3: $(subst -etcd3,,$@)
docker-optionfactory-centos8-etcd3: sync-etcd3 docker-optionfactory-centos8
docker-optionfactory-debian10-etcd3: sync-etcd3 docker-optionfactory-debian10
docker-optionfactory-ubuntu20-etcd3: sync-etcd3 docker-optionfactory-ubuntu20
docker-optionfactory-rocky8-etcd3: sync-etcd3 docker-optionfactory-rocky8

#docker-optionfactory-%-journal-remote: $(subst -journal-remote,,$@)
docker-optionfactory-centos8-journal-remote: sync-journal-remote docker-optionfactory-centos8
docker-optionfactory-debian10-journal-remote: sync-journal-remote docker-optionfactory-debian10
docker-optionfactory-ubuntu20-journal-remote: sync-journal-remote docker-optionfactory-ubuntu20
docker-optionfactory-rocky8-journal-remote: sync-journal-remote docker-optionfactory-rocky8

#docker-optionfactory-%-jdk11-tomcat9: $(subst -tomcat9,,$@)
docker-optionfactory-centos8-jdk11-tomcat9: sync-tomcat9 docker-optionfactory-centos8-jdk11
docker-optionfactory-debian10-jdk11-tomcat9: sync-tomcat9 docker-optionfactory-debian10-jdk11
docker-optionfactory-ubuntu20-jdk11-tomcat9: sync-tomcat9 docker-optionfactory-ubuntu20-jdk11
docker-optionfactory-rocky8-jdk11-tomcat9: sync-tomcat9 docker-optionfactory-rocky8-jdk11

#docker-optionfactory-%-jdk11-keycloak12: $(subst -keycloak12,,$@)
docker-optionfactory-centos8-jdk11-keycloak12: sync-psql-jdbc sync-keycloak12 docker-optionfactory-centos8-jdk11
docker-optionfactory-debian10-jdk11-keycloak12: sync-psql-jdbc sync-keycloak12 docker-optionfactory-debian10-jdk11
docker-optionfactory-ubuntu20-jdk11-keycloak12: sync-psql-jdbc sync-keycloak12 docker-optionfactory-ubuntu20-jdk11
docker-optionfactory-rocky8-jdk11-keycloak12: sync-psql-jdbc sync-keycloak12 docker-optionfactory-rocky8-jdk11


#docker-optionfactory-%-jdk11-keycloak14: $(subst -keycloak12,,$@)
docker-optionfactory-centos8-jdk11-keycloak14: sync-psql-jdbc sync-keycloak14 docker-optionfactory-centos8-jdk11
docker-optionfactory-debian10-jdk11-keycloak14: sync-psql-jdbc sync-keycloak14 docker-optionfactory-debian10-jdk11
docker-optionfactory-ubuntu20-jdk11-keycloak14: sync-psql-jdbc sync-keycloak14 docker-optionfactory-ubuntu20-jdk11
docker-optionfactory-rocky8-jdk11-keycloak14: sync-psql-jdbc sync-keycloak14 docker-optionfactory-rocky8-jdk11


#docker-optionfactory-%-restalpr: $(subst -restalpr,,$@)
docker-optionfactory-centos8-restalpr: sync-restalpr docker-optionfactory-centos8
docker-optionfactory-debian10-restalpr: sync-restalpr docker-optionfactory-debian10
docker-optionfactory-ubuntu20-restalpr: sync-restalpr docker-optionfactory-ubuntu20
docker-optionfactory-rocky8-restalpr: sync-restalpr docker-optionfactory-rocky8



docker-optionfactory-%:
	@echo building $@
	$(eval name=$(subst docker-optionfactory-,,$@))
	docker build ${DOCKER_BUILD_OPTIONS} --tag=optionfactory/$(name):${TAG_VERSION} optionfactory-$(name)
	docker tag optionfactory/$(name):${TAG_VERSION} optionfactory/$(name):latest



sync: sync-tools sync-jdk11 sync-tomcat9 sync-keycloak12 sync-keycloak14 sync-nginx120 sync-mariadb10 sync-postgres12 sync-etcd3 sync-golang1 sync-psql-jdbc

sync-tools: deps/gosu1 deps/spawn-and-tail1
	@echo "syncing gosu"
	@echo optionfactory-centos8/deps optionfactory-debian10/deps optionfactory-ubuntu20/deps | xargs -n 1 rsync -az deps/gosu-${GOSU1_VERSION}
	@echo "syncing ps1"
	@echo optionfactory-centos8/deps optionfactory-debian10/deps optionfactory-ubuntu20/deps | xargs -n 1 rsync -az install-ps1.sh
	@echo "syncing spawn-and-tail"
	@echo optionfactory-centos8/deps optionfactory-debian10/deps optionfactory-ubuntu20/deps | xargs -n 1 rsync -az install-spawn-and-tail.sh
	@echo optionfactory-centos8/deps optionfactory-debian10/deps optionfactory-ubuntu20/deps | xargs -n 1 rsync -az deps/spawn-and-tail-${SPAWN_AND_TAIL_VERSION}
sync-jdk11: deps/jdk11
	@echo "syncing jdk 11"
	@echo optionfactory-*-jdk11/deps | xargs -n 1 rsync -az install-jdk11.sh
	@echo optionfactory-*-jdk11/deps | xargs -n 1 rsync -az deps/jdk-${JDK11_VERSION}+${JDK11_BUILD}
sync-builder: deps/maven3
	@echo "syncing maven 3"
	@echo optionfactory-*-jdk11-builder/deps | xargs -n 1 rsync -az install-builder.sh
	@echo optionfactory-*-jdk11-builder/deps | xargs -n 1 rsync -az deps/apache-maven-${MAVEN3_VERSION}
sync-tomcat9: deps/tomcat9
	@echo "syncing tomcat 9"
	@echo optionfactory-*-tomcat9/deps | xargs -n 1 rsync -az install-tomcat9.sh
	@echo optionfactory-*-tomcat9/deps | xargs -n 1 rsync -az init-tomcat9.sh
	@echo optionfactory-*-tomcat9/deps | xargs -n 1 rsync -az deps/apache-tomcat-${TOMCAT9_VERSION}
	@echo optionfactory-*-tomcat9/deps | xargs -n 1 rsync -az deps/tomcat9-logging-error-report-valve-${TOMCAT9_ERROR_REPORT_VALVE_VERSION}.jar
sync-keycloak12: deps/keycloak12
	@echo "syncing keycloak 12"
	@echo optionfactory-*-keycloak12/deps | xargs -n 1 rsync -az install-keycloak12.sh
	@echo optionfactory-*-keycloak12/deps | xargs -n 1 rsync -az init-keycloak12.sh
	@echo optionfactory-*-keycloak12/deps | xargs -n 1 rsync -az deps/keycloak-${KEYCLOAK12_VERSION}
sync-keycloak14: deps/keycloak14
	@echo "syncing keycloak 14"
	@echo optionfactory-*-keycloak14/deps | xargs -n 1 rsync -az install-keycloak14.sh
	@echo optionfactory-*-keycloak14/deps | xargs -n 1 rsync -az init-keycloak14.sh
	@echo optionfactory-*-keycloak14/deps | xargs -n 1 rsync -az deps/keycloak-${KEYCLOAK14_VERSION}	
sync-nginx120:
	@echo optionfactory-*-nginx120/deps | xargs -n 1 rsync -az install-nginx120.sh
	@echo optionfactory-*-nginx120/deps | xargs -n 1 rsync -az init-nginx120.sh
sync-mariadb10: deps/mariadb10
	@echo "syncing mariadb 10"
	@echo optionfactory-*-mariadb10/deps | xargs -n 1 rsync -az install-mariadb10.sh
	@echo optionfactory-*-mariadb10/deps | xargs -n 1 rsync -az init-mariadb10.sh
sync-postgres12: deps/postgres12
	@echo "syncing postgres 12"
	@echo optionfactory-*-postgres12/deps | xargs -n 1 rsync -az install-postgres12.sh
	@echo optionfactory-*-postgres12/deps | xargs -n 1 rsync -az init-postgres12.sh
sync-barman2: deps/barman2
	@echo "syncing barman 2"
	@echo optionfactory-*-barman2/deps | xargs -n 1 rsync -az install-barman2.sh
	@echo optionfactory-*-barman2/deps | xargs -n 1 rsync -az init-barman2.sh
sync-etcd3: deps/etcd3
	@echo "syncing etcd3"
	@echo optionfactory-*-etcd3/deps | xargs -n 1 rsync -az install-etcd3.sh
	@echo optionfactory-*-etcd3/deps | xargs -n 1 rsync -az init-etcd3.sh
	@echo optionfactory-*-etcd3/deps | xargs -n 1 rsync -az deps/etcd-v${ETCD3_VERSION}-linux-amd64
sync-journal-remote:
	@echo "syncing journal-remote"
	@echo optionfactory-*-journal-remote/deps | xargs -n 1 rsync -az install-journal-remote.sh
	@echo optionfactory-*-journal-remote/deps | xargs -n 1 rsync -az init-journal-remote.sh

sync-golang1: deps/golang1
	@echo "syncing golang"
	@echo optionfactory-*-golang1/deps | xargs -n 1 rsync -az install-golang1.sh
	@echo optionfactory-*-golang1/deps | xargs -n 1 rsync -az init-golang1.sh
	@echo optionfactory-*-golang1/deps | xargs -n 1 rsync -az golang1-project-makefile.tpl
	@echo optionfactory-*-golang1 | sed -r 's/optionfactory-(\w+)-golang1/\1\n/g' | xargs -n 1 -I% sed -i "s/{{DISTRO}}/%/g" optionfactory-%-golang1/deps/golang1-project-makefile.tpl
	@echo optionfactory-*-golang1/deps | xargs -n 1 rsync -az deps/golang-${GOLANG1_VERSION}
sync-psql-jdbc: deps/psql-jdbc
	@echo "syncing psql-jdbc driver"
	@echo optionfactory-*-keycloak12/deps | xargs -n 1 rsync -az deps/postgresql-${PSQL_JDBC_VERSION}.jar
	@echo optionfactory-*-keycloak14/deps | xargs -n 1 rsync -az deps/postgresql-${PSQL_JDBC_VERSION}.jar
sync-restalpr: deps/restalpr
	@echo "syncing alpr"
	@echo optionfactory-*-restalpr/deps | xargs -n 1 rsync -az install-restalpr.sh
	@echo optionfactory-*-restalpr/deps | xargs -n 1 rsync -az init-restalpr.sh


deps: deps/gosu1 deps/spawn-and-tail1 deps/jdk11 deps/tomcat9 deps/keycloak12 deps/psql-jdbc deps/mariadb10 deps/postgres12 deps/barman2 deps/golang1 deps/etcd3

deps/gosu1: deps/gosu-${GOSU1_VERSION}
deps/spawn-and-tail1: deps/spawn-and-tail-${SPAWN_AND_TAIL_VERSION}
deps/jdk11: deps/jdk-${JDK11_VERSION}+${JDK11_BUILD}
deps/maven3: deps/apache-maven-${MAVEN3_VERSION}
deps/tomcat9: deps/apache-tomcat-${TOMCAT9_VERSION} deps/tomcat9-logging-error-report-valve-${TOMCAT9_ERROR_REPORT_VALVE_VERSION}.jar
deps/keycloak12: deps/keycloak-${KEYCLOAK12_VERSION}
deps/keycloak14: deps/keycloak-${KEYCLOAK14_VERSION}
deps/psql-jdbc: deps/postgresql-${PSQL_JDBC_VERSION}.jar
deps/mariadb10:
deps/postgres12:
deps/barman2:
deps/golang1: deps/golang-${GOLANG1_VERSION}/bin/go
deps/etcd3: deps/etcd-v${ETCD3_VERSION}-linux-amd64
deps/restalpr:

deps/jdk-${JDK11_VERSION}+${JDK11_BUILD}:
	curl -# -j -k -L https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-${JDK11_VERSION}%2B${JDK11_BUILD}/OpenJDK11U-jdk_x64_linux_hotspot_${JDK11_VERSION}_${JDK11_BUILD}.tar.gz | tar xz -C deps
deps/apache-maven-${MAVEN3_VERSION}:
	curl -# -j -k -L https://downloads.apache.org/maven/maven-3/${MAVEN3_VERSION}/binaries/apache-maven-${MAVEN3_VERSION}-bin.tar.gz | tar xz -C deps
deps/apache-tomcat-${TOMCAT9_VERSION}:
	curl -# -sSL -k https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT9_VERSION}/bin/apache-tomcat-${TOMCAT9_VERSION}.tar.gz | tar xz -C deps
deps/tomcat9-logging-error-report-valve-${TOMCAT9_ERROR_REPORT_VALVE_VERSION}.jar:
	curl -# -j -k -L  https://repo1.maven.org/maven2/net/optionfactory/tomcat9-logging-error-report-valve/${TOMCAT9_ERROR_REPORT_VALVE_VERSION}/tomcat9-logging-error-report-valve-${TOMCAT9_ERROR_REPORT_VALVE_VERSION}.jar -o deps/tomcat9-logging-error-report-valve-${TOMCAT9_ERROR_REPORT_VALVE_VERSION}.jar
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
	curl -# -j -k -L  https://github.com/etcd-io/etcd/releases/download/v${ETCD3_VERSION}/etcd-v${ETCD3_VERSION}-linux-amd64.tar.gz | tar xz -C deps
deps/keycloak-${KEYCLOAK12_VERSION}:
	curl -# -j -k -L  https://github.com/keycloak/keycloak/releases/download/${KEYCLOAK12_VERSION}/keycloak-${KEYCLOAK12_VERSION}.tar.gz | tar xz -C deps
deps/keycloak-${KEYCLOAK14_VERSION}:
	curl -# -j -k -L  https://github.com/keycloak/keycloak/releases/download/${KEYCLOAK14_VERSION}/keycloak-${KEYCLOAK14_VERSION}.tar.gz | tar xz -C deps
deps/postgresql-${PSQL_JDBC_VERSION}.jar:
	curl -# -j -k -L  https://repo1.maven.org/maven2/org/postgresql/postgresql/${PSQL_JDBC_VERSION}/postgresql-${PSQL_JDBC_VERSION}.jar -o deps/postgresql-${PSQL_JDBC_VERSION}.jar
deps/restalpr:
	#TODO: curl go-webservice

clean: FORCE
	rm -rf optionfactory-*/install-*.sh
	rm -rf optionfactory-*/deps/*

clean-deps: FORCE
	rm -rf deps/*

cleanup-docker-images:
	-docker images --quiet --filter=dangling=true | xargs --no-run-if-empty docker rmi
	-docker volume prune -f

#If a rule has no prerequisites or recipe, and the target of the rule is a nonexistent file,
#then make imagines this target to have been updated whenever its rule is run.
#This implies that all targets depending on this one will always have their recipe run.
FORCE:
.PHONY: sync deps docker-images clean clean-deps

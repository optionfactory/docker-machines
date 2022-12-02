#we user squash here to remove unwanted layers, which is an experimental feature
#{"experimental": true} > /etc/docker/daemon.json
DOCKER_BUILD_OPTIONS=--no-cache=false --squash
TAG_VERSION=40

#software versions
JDK11_VERSION=11.0.17
JDK11_BUILD=8
JDK17_VERSION=17.0.5
JDK17_BUILD=8
JDK19_VERSION=19.0.1
JDK19_BUILD=10

TOMCAT9_VERSION=9.0.69
TOMCAT9_ERROR_REPORT_VALVE_VERSION=2.0
TOMCAT10_VERSION=10.1.2
TOMCAT10_ERROR_REPORT_VALVE_VERSION=2.0
GOSU1_VERSION=1.14
GOLANG1_VERSION=1.19.3
ETCD3_VERSION=3.5.6
KEYCLOAK1_VERSION=20.0.1
KEYCLOAK_OPFA_MODULES_VERSION=2.1
MAVEN3_VERSION=3.8.6
#/software versions


define task
	@echo "\033[1;32m"$(1)"\033[0m"
endef

define irun 
    @$(1) | sed 's/^/    /'
endef

help:
	@echo usage: make [clean-deps] [clean] sync docker-images
	@echo usage: make [clean-deps] [clean] docker-optionfactory-rocky9-mariadb10
	exit 1

docker-images: sync-base-images $(addprefix docker-,$(wildcard optionfactory-*))

docker-push:
	$(call task,pushing tag: ${TAG_VERSION})
	$(call irun,docker images --filter="reference=optionfactory/*:${TAG_VERSION}" --format='{{.Repository}}' | sort | uniq |  xargs -I'{}' docker push {}:${TAG_VERSION})
	$(call task,pushing tag: latest)
	$(call irun,docker images --filter="reference=optionfactory/*:${TAG_VERSION}" --format='{{.Repository}}' | sort | uniq |  xargs -I'{}' docker push {}:latest)


docker-optionfactory-debian11: sync-tools
docker-optionfactory-ubuntu22: sync-tools
docker-optionfactory-rocky9: sync-tools

#docker-optionfactory-%-jdk11: $(subst -jdk11,,$@)
docker-optionfactory-debian11-jdk11: sync-jdk11 docker-optionfactory-debian11
docker-optionfactory-ubuntu22-jdk11: sync-jdk11 docker-optionfactory-ubuntu22
docker-optionfactory-rocky9-jdk11: sync-jdk11 docker-optionfactory-rocky9

#docker-optionfactory-%-jdk17: $(subst -jdk17,,$@)
docker-optionfactory-debian11-jdk17: sync-jdk17 docker-optionfactory-debian11
docker-optionfactory-ubuntu22-jdk17: sync-jdk17 docker-optionfactory-ubuntu22
docker-optionfactory-rocky9-jdk17: sync-jdk17 docker-optionfactory-rocky9

#docker-optionfactory-%-jdk19: $(subst -jdk17,,$@)
docker-optionfactory-debian11-jdk19: sync-jdk19 docker-optionfactory-debian11
docker-optionfactory-ubuntu22-jdk19: sync-jdk19 docker-optionfactory-ubuntu22
docker-optionfactory-rocky9-jdk19: sync-jdk19 docker-optionfactory-rocky9

#docker-optionfactory-%-jdk11-builder: $(subst -jdk11-builder,,$@)
docker-optionfactory-debian11-jdk11-builder: sync-builder docker-optionfactory-debian11-jdk11
docker-optionfactory-ubuntu22-jdk11-builder: sync-builder docker-optionfactory-ubuntu22-jdk11
docker-optionfactory-rocky9-jdk11-builder: sync-builder docker-optionfactory-rocky9-jdk11

#docker-optionfactory-%-jdk17-builder: $(subst -jdk17-builder,,$@)
docker-optionfactory-debian11-jdk17-builder: sync-builder docker-optionfactory-debian11-jdk17
docker-optionfactory-ubuntu22-jdk17-builder: sync-builder docker-optionfactory-ubuntu22-jdk17
docker-optionfactory-rocky9-jdk17-builder: sync-builder docker-optionfactory-rocky9-jdk17

#docker-optionfactory-%-nginx120: $(subst -nginx120,,$@)
docker-optionfactory-debian11-nginx120: sync-nginx120 docker-optionfactory-debian11
docker-optionfactory-ubuntu22-nginx120: sync-nginx120 docker-optionfactory-ubuntu22
docker-optionfactory-rocky9-nginx120: sync-nginx120 docker-optionfactory-rocky9

#docker-optionfactory-%-mariadb10: $(subst -mariadb10,,$@)
docker-optionfactory-debian11-mariadb10: sync-mariadb10 docker-optionfactory-debian11
docker-optionfactory-ubuntu22-mariadb10: sync-mariadb10 docker-optionfactory-ubuntu22
docker-optionfactory-rocky9-mariadb10: sync-mariadb10 docker-optionfactory-rocky9

#docker-optionfactory-%-postgres12: $(subst -postgres12,,$@)
docker-optionfactory-debian11-postgres12: sync-postgres docker-optionfactory-debian11
docker-optionfactory-ubuntu22-postgres12: sync-postgres docker-optionfactory-ubuntu22
docker-optionfactory-rocky9-postgres12: sync-postgres docker-optionfactory-rocky9

#docker-optionfactory-%-postgres14: $(subst -postgres14,,$@)
docker-optionfactory-debian11-postgres14: sync-postgres docker-optionfactory-debian11
docker-optionfactory-ubuntu22-postgres14: sync-postgres docker-optionfactory-ubuntu22
docker-optionfactory-rocky9-postgres14: sync-postgres docker-optionfactory-rocky9

#docker-optionfactory-%-postgres15: $(subst -postgres15,,$@)
docker-optionfactory-debian11-postgres15: sync-postgres docker-optionfactory-debian11
docker-optionfactory-ubuntu22-postgres15: sync-postgres docker-optionfactory-ubuntu22
docker-optionfactory-rocky9-postgres15: sync-postgres docker-optionfactory-rocky9

#docker-optionfactory-%-barman2: $(subst -barman2,,$@)
docker-optionfactory-debian11-barman2: sync-barman2 docker-optionfactory-debian11
docker-optionfactory-ubuntu22-barman2: sync-barman2 docker-optionfactory-ubuntu22
docker-optionfactory-rocky9-barman2: sync-barman2 docker-optionfactory-rocky9

#docker-optionfactory-%-golang1: $(subst -golang1,,$@)
docker-optionfactory-debian11-golang1: sync-golang1 docker-optionfactory-debian11
docker-optionfactory-ubuntu22-golang1: sync-golang1 docker-optionfactory-ubuntu22
docker-optionfactory-rocky9-golang1: sync-golang1 docker-optionfactory-rocky9

#docker-optionfactory-%-etcd3: $(subst -etcd3,,$@)
docker-optionfactory-debian11-etcd3: sync-etcd3 docker-optionfactory-debian11
docker-optionfactory-ubuntu22-etcd3: sync-etcd3 docker-optionfactory-ubuntu22
docker-optionfactory-rocky9-etcd3: sync-etcd3 docker-optionfactory-rocky9

#docker-optionfactory-%-journal-remote: $(subst -journal-remote,,$@)
docker-optionfactory-debian11-journal-remote: sync-journal-remote docker-optionfactory-debian11
docker-optionfactory-ubuntu22-journal-remote: sync-journal-remote docker-optionfactory-ubuntu22
docker-optionfactory-rocky9-journal-remote: sync-journal-remote docker-optionfactory-rocky9

#docker-optionfactory-%-jdk11-tomcat9: $(subst -tomcat9,,$@)
docker-optionfactory-debian11-jdk11-tomcat9: sync-tomcat9 docker-optionfactory-debian11-jdk11
docker-optionfactory-ubuntu22-jdk11-tomcat9: sync-tomcat9 docker-optionfactory-ubuntu22-jdk11
docker-optionfactory-rocky9-jdk11-tomcat9: sync-tomcat9 docker-optionfactory-rocky9-jdk11

#docker-optionfactory-%-jdk17-tomcat9: $(subst -tomcat9,,$@)
docker-optionfactory-debian11-jdk17-tomcat9: sync-tomcat9 docker-optionfactory-debian11-jdk17
docker-optionfactory-ubuntu22-jdk17-tomcat9: sync-tomcat9 docker-optionfactory-ubuntu22-jdk17
docker-optionfactory-rocky9-jdk17-tomcat9: sync-tomcat9 docker-optionfactory-rocky9-jdk17

#docker-optionfactory-%-jdk19-tomcat9: $(subst -tomcat9,,$@)
docker-optionfactory-debian11-jdk19-tomcat9: sync-tomcat9 docker-optionfactory-debian11-jdk19
docker-optionfactory-ubuntu22-jdk19-tomcat9: sync-tomcat9 docker-optionfactory-ubuntu22-jdk19
docker-optionfactory-rocky9-jdk19-tomcat9: sync-tomcat9 docker-optionfactory-rocky9-jdk19

#docker-optionfactory-%-jdk19-tomcat10: $(subst -tomcat9,,$@)
docker-optionfactory-debian11-jdk19-tomcat10: sync-tomcat10 docker-optionfactory-debian11-jdk19
docker-optionfactory-ubuntu22-jdk19-tomcat10: sync-tomcat10 docker-optionfactory-ubuntu22-jdk19
docker-optionfactory-rocky9-jdk19-tomcat10: sync-tomcat10 docker-optionfactory-rocky9-jdk19

#docker-optionfactory-%-jdk17-quarkus-keycloak1: $(subst -quarkus-keycloak1,,$@)
docker-optionfactory-debian11-jdk17-quarkus-keycloak1: sync-quarkus-keycloak1 docker-optionfactory-debian11-jdk17
docker-optionfactory-ubuntu22-jdk17-quarkus-keycloak1: sync-quarkus-keycloak1 docker-optionfactory-ubuntu22-jdk17
docker-optionfactory-rocky9-jdk17-quarkus-keycloak1: sync-quarkus-keycloak1 docker-optionfactory-rocky9-jdk17

#docker-optionfactory-%-jdk11-quarkus-keycloak1: $(subst -quarkus-keycloak1,,$@)
docker-optionfactory-debian11-jdk11-quarkus-keycloak1: sync-quarkus-keycloak1 docker-optionfactory-debian11-jdk11
docker-optionfactory-ubuntu22-jdk11-quarkus-keycloak1: sync-quarkus-keycloak1 docker-optionfactory-ubuntu22-jdk11
docker-optionfactory-rocky9-jdk11-quarkus-keycloak1: sync-quarkus-keycloak1 docker-optionfactory-rocky9-jdk11



docker-optionfactory-%:
	$(call task,building $@)
	$(eval name=$(subst docker-optionfactory-,,$@))
	$(call irun,docker build ${DOCKER_BUILD_OPTIONS} --tag=optionfactory/$(name):${TAG_VERSION} optionfactory-$(name))
	$(call irun,docker tag optionfactory/$(name):${TAG_VERSION} optionfactory/$(name):latest)

sync: sync-base-images sync-tools sync-jdk11 sync-jdk17 sync-jdk19 sync-builder sync-tomcat9 sync-tomcat10 sync-quarkus-keycloak1 sync-nginx120 sync-mariadb10 sync-postgres sync-barman2 sync-etcd3 sync-journal-remote sync-golang1

sync-base-images:
	$(call task,updating base images)
	$(call irun,docker pull debian:bullseye)
	$(call irun,docker pull rockylinux/rockylinux:9)
	$(call irun,docker pull ubuntu:22.04)

sync-tools: deps/gosu1 
	$(call task,syncing gosu)
	$(call irun,echo optionfactory-rocky9/deps optionfactory-debian11/deps optionfactory-ubuntu22/deps | xargs -n 1 rsync -az deps/gosu-${GOSU1_VERSION})
	$(call task,syncing ps1)
	$(call irun,echo optionfactory-rocky9/deps optionfactory-debian11/deps optionfactory-ubuntu22/deps | xargs -n 1 rsync -az install-ps1.sh)
sync-jdk11: deps/jdk11
	$(call task,syncing jdk 11)
	$(call irun,echo optionfactory-*-jdk11/deps | xargs -n 1 rsync -az install-jdk.sh)
	$(call irun,echo optionfactory-*-jdk11/deps | xargs -n 1 rsync -az deps/jdk-${JDK11_VERSION}+${JDK11_BUILD})
sync-jdk17: deps/jdk17
	$(call task,syncing jdk 17)
	$(call irun,echo optionfactory-*-jdk17/deps | xargs -n 1 rsync -az install-jdk.sh)
	$(call irun,echo optionfactory-*-jdk17/deps | xargs -n 1 rsync -az deps/jdk-${JDK17_VERSION}+${JDK17_BUILD})
sync-jdk19: deps/jdk19
	$(call task,syncing jdk 19)
	$(call irun,echo optionfactory-*-jdk19/deps | xargs -n 1 rsync -az install-jdk.sh)
	$(call irun,echo optionfactory-*-jdk19/deps | xargs -n 1 rsync -az deps/jdk-${JDK19_VERSION}+${JDK19_BUILD})
sync-builder: deps/maven3
	$(call task,syncing maven 3)
	$(call irun,echo optionfactory-*-jdk*-builder/deps | xargs -n 1 rsync -az install-builder.sh)
	$(call irun,echo optionfactory-*-jdk*-builder/deps | xargs -n 1 rsync -az deps/apache-maven-${MAVEN3_VERSION})
sync-tomcat9: deps/tomcat9
	$(call task,syncing tomcat 9)
	$(call irun,echo optionfactory-*-tomcat9/deps | xargs -n 1 rsync -az install-tomcat.sh)
	$(call irun,echo optionfactory-*-tomcat9/deps | xargs -n 1 rsync -az init-tomcat.sh)
	$(call irun,echo optionfactory-*-tomcat9/deps | xargs -n 1 rsync -az deps/apache-tomcat-${TOMCAT9_VERSION})
	$(call irun,echo optionfactory-*-tomcat9/deps | xargs -n 1 rsync -az deps/tomcat9-logging-error-report-valve-${TOMCAT9_ERROR_REPORT_VALVE_VERSION}.jar)
sync-tomcat10: deps/tomcat10
	$(call task,syncing tomcat 10)
	$(call irun,echo optionfactory-*-tomcat10/deps | xargs -n 1 rsync -az install-tomcat.sh)
	$(call irun,echo optionfactory-*-tomcat10/deps | xargs -n 1 rsync -az init-tomcat.sh)
	$(call irun,echo optionfactory-*-tomcat10/deps | xargs -n 1 rsync -az deps/apache-tomcat-${TOMCAT10_VERSION})
	$(call irun,echo optionfactory-*-tomcat10/deps | xargs -n 1 rsync -az deps/tomcat10-logging-error-report-valve-${TOMCAT10_ERROR_REPORT_VALVE_VERSION}.jar)
sync-quarkus-keycloak1: deps/quarkus-keycloak1
	$(call task,syncing quarkus-keycloak)
	$(call irun,echo optionfactory-*-quarkus-keycloak1/deps | xargs -n 1 rsync -az install-quarkus-keycloak1.sh)
	$(call irun,echo optionfactory-*-quarkus-keycloak1/deps | xargs -n 1 rsync -az init-quarkus-keycloak1.sh)
	$(call irun,echo optionfactory-*-quarkus-keycloak1/deps | xargs -n 1 rsync -az deps/keycloak-${KEYCLOAK1_VERSION})
	$(call irun,echo optionfactory-*-quarkus-keycloak1/deps | xargs -n 1 rsync -az deps/optionfactory-keycloak-${KEYCLOAK_OPFA_MODULES_VERSION})
sync-nginx120:
	$(call task,syncing nginx)
	$(call irun,echo optionfactory-*-nginx120/deps | xargs -n 1 rsync -az install-nginx120.sh)
	$(call irun,echo optionfactory-*-nginx120/deps | xargs -n 1 rsync -az init-nginx120.sh)
sync-mariadb10: deps/mariadb10
	$(call task,syncing mariadb 10)
	$(call irun,echo optionfactory-*-mariadb10/deps | xargs -n 1 rsync -az install-mariadb10.sh)
	$(call irun,echo optionfactory-*-mariadb10/deps | xargs -n 1 rsync -az init-mariadb10.sh)
sync-postgres: deps/postgres
	$(call task,syncing postgres)
	$(call irun,echo optionfactory-*-postgres*/deps | xargs -n 1 rsync -az install-postgres.sh)
	$(call irun,echo optionfactory-*-postgres*/deps | xargs -n 1 rsync -az init-postgres.sh)
sync-barman2: deps/barman2
	$(call task,syncing barman2)
	$(call irun,echo optionfactory-*-barman2/deps | xargs -n 1 rsync -az install-barman2.sh)
	$(call irun,echo optionfactory-*-barman2/deps | xargs -n 1 rsync -az init-barman2.sh)
sync-etcd3: deps/etcd3
	$(call task,syncing etcd3)
	$(call irun,echo optionfactory-*-etcd3/deps | xargs -n 1 rsync -az install-etcd3.sh)
	$(call irun,echo optionfactory-*-etcd3/deps | xargs -n 1 rsync -az init-etcd3.sh)
	$(call irun,echo optionfactory-*-etcd3/deps | xargs -n 1 rsync -az deps/etcd-v${ETCD3_VERSION}-linux-amd64)
sync-journal-remote:
	$(call task,syncing journal-remote)
	$(call irun,echo optionfactory-*-journal-remote/deps | xargs -n 1 rsync -az install-journal-remote.sh)
	$(call irun,echo optionfactory-*-journal-remote/deps | xargs -n 1 rsync -az init-journal-remote.sh)
sync-golang1: deps/golang1
	$(call task,syncing golang)
	$(call irun,echo optionfactory-*-golang1/deps | xargs -n 1 rsync -az install-golang1.sh)
	$(call irun,echo optionfactory-*-golang1/deps | xargs -n 1 rsync -az deps/golang-${GOLANG1_VERSION})


deps: deps/gosu1 deps/jdk11 deps/tomcat9 deps/wildfly-keycloak1 deps/quarkus-keycloak1 deps/psql-jdbc deps/mariadb10 deps/postgres12 deps/barman2 deps/golang1 deps/etcd3

deps/gosu1: deps/gosu-${GOSU1_VERSION}
deps/jdk11: deps/jdk-${JDK11_VERSION}+${JDK11_BUILD}
deps/jdk17: deps/jdk-${JDK17_VERSION}+${JDK17_BUILD}
deps/jdk19: deps/jdk-${JDK19_VERSION}+${JDK19_BUILD}
deps/maven3: deps/apache-maven-${MAVEN3_VERSION}
deps/tomcat9: deps/apache-tomcat-${TOMCAT9_VERSION} deps/tomcat9-logging-error-report-valve-${TOMCAT9_ERROR_REPORT_VALVE_VERSION}.jar
deps/tomcat10: deps/apache-tomcat-${TOMCAT10_VERSION} deps/tomcat10-logging-error-report-valve-${TOMCAT10_ERROR_REPORT_VALVE_VERSION}.jar
deps/quarkus-keycloak1: deps/keycloak-${KEYCLOAK1_VERSION} deps/optionfactory-keycloak-${KEYCLOAK_OPFA_MODULES_VERSION}
deps/mariadb10:
deps/postgres:
deps/barman2:
deps/golang1: deps/golang-${GOLANG1_VERSION}/bin/go
deps/etcd3: deps/etcd-v${ETCD3_VERSION}-linux-amd64

deps/jdk-${JDK11_VERSION}+${JDK11_BUILD}:
	$(call irun,curl -# -j -k -L https://github.com/adoptium/temurin11-binaries/releases/download/jdk-${JDK11_VERSION}%2B${JDK11_BUILD}/OpenJDK11U-jdk_x64_linux_hotspot_${JDK11_VERSION}_${JDK11_BUILD}.tar.gz	| tar xz -C deps)
deps/jdk-${JDK17_VERSION}+${JDK17_BUILD}:
	$(call irun,curl -# -j -k -L https://github.com/adoptium/temurin17-binaries/releases/download/jdk-${JDK17_VERSION}%2B${JDK17_BUILD}/OpenJDK17U-jdk_x64_linux_hotspot_${JDK17_VERSION}_${JDK17_BUILD}.tar.gz	| tar xz -C deps)
deps/jdk-${JDK19_VERSION}+${JDK19_BUILD}:
	$(call irun,curl -# -j -k -L https://github.com/adoptium/temurin19-binaries/releases/download/jdk-${JDK19_VERSION}%2B${JDK19_BUILD}/OpenJDK19U-jdk_x64_linux_hotspot_${JDK19_VERSION}_${JDK19_BUILD}.tar.gz	| tar xz -C deps)
deps/apache-maven-${MAVEN3_VERSION}:
	$(call irun,curl -# -j -k -L https://downloads.apache.org/maven/maven-3/${MAVEN3_VERSION}/binaries/apache-maven-${MAVEN3_VERSION}-bin.tar.gz | tar xz -C deps)
deps/apache-tomcat-${TOMCAT9_VERSION}:
	$(call irun,curl -# -sSL -k https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT9_VERSION}/bin/apache-tomcat-${TOMCAT9_VERSION}.tar.gz | tar xz -C deps)
deps/tomcat9-logging-error-report-valve-${TOMCAT9_ERROR_REPORT_VALVE_VERSION}.jar:
	$(call irun,curl -# -j -k -L  https://repo1.maven.org/maven2/net/optionfactory/tomcat9-logging-error-report-valve/${TOMCAT9_ERROR_REPORT_VALVE_VERSION}/tomcat9-logging-error-report-valve-${TOMCAT9_ERROR_REPORT_VALVE_VERSION}.jar -o deps/tomcat9-logging-error-report-valve-${TOMCAT9_ERROR_REPORT_VALVE_VERSION}.jar)
deps/apache-tomcat-${TOMCAT10_VERSION}:
	$(call irun,curl -# -sSL -k https://archive.apache.org/dist/tomcat/tomcat-10/v${TOMCAT10_VERSION}/bin/apache-tomcat-${TOMCAT10_VERSION}.tar.gz | tar xz -C deps)
deps/tomcat10-logging-error-report-valve-${TOMCAT10_ERROR_REPORT_VALVE_VERSION}.jar:
	$(call irun,curl -# -j -k -L  https://repo1.maven.org/maven2/net/optionfactory/tomcat9-logging-error-report-valve/${TOMCAT10_ERROR_REPORT_VALVE_VERSION}/tomcat9-logging-error-report-valve-${TOMCAT9_ERROR_REPORT_VALVE_VERSION}.jar -o deps/tomcat10-logging-error-report-valve-${TOMCAT9_ERROR_REPORT_VALVE_VERSION}.jar)
deps/gosu-${GOSU1_VERSION}:
	$(call irun,curl -# -sSL -k https://github.com/tianon/gosu/releases/download/${GOSU1_VERSION}/gosu-amd64 -o deps/gosu-${GOSU1_VERSION})
	$(call irun,chmod +x deps/gosu-${GOSU1_VERSION})
deps/golang-${GOLANG1_VERSION}/bin/go:
	$(call irun,mkdir -p deps/golang-${GOLANG1_VERSION})
	$(call irun,curl -# -j -k -L https://golang.org/dl/go${GOLANG1_VERSION}.linux-amd64.tar.gz | tar xz -C deps/golang-${GOLANG1_VERSION} --strip-components=1)
deps/etcd-v${ETCD3_VERSION}-linux-amd64:
	$(call irun,curl -# -j -k -L  https://github.com/etcd-io/etcd/releases/download/v${ETCD3_VERSION}/etcd-v${ETCD3_VERSION}-linux-amd64.tar.gz | tar xz -C deps)
deps/keycloak-${KEYCLOAK1_VERSION}:
	$(call irun,curl -# -j -k -L  https://github.com/keycloak/keycloak/releases/download/${KEYCLOAK1_VERSION}/keycloak-${KEYCLOAK1_VERSION}.tar.gz | tar xz -C deps)
deps/optionfactory-keycloak-${KEYCLOAK_OPFA_MODULES_VERSION}:
	$(call irun,mkdir -p deps/optionfactory-keycloak-${KEYCLOAK_OPFA_MODULES_VERSION})
	$(eval modules=$(shell curl https://repo1.maven.org/maven2/net/optionfactory/keycloak/optionfactory-keycloak/${KEYCLOAK_OPFA_MODULES_VERSION}/optionfactory-keycloak-${KEYCLOAK_OPFA_MODULES_VERSION}.pom | grep '<module>' | grep -Po '(?<=>)[^<]+(?=<)'))
	$(call irun,for module in ${modules}; do curl -# -j -k -L "https://repo1.maven.org/maven2/net/optionfactory/keycloak/$${module}/${KEYCLOAK_OPFA_MODULES_VERSION}/$${module}-${KEYCLOAK_OPFA_MODULES_VERSION}.jar" > "deps/optionfactory-keycloak-${KEYCLOAK_OPFA_MODULES_VERSION}/$${module}.jar"; done)

clean: FORCE
	$(call task,removing install scripts)
	$(call irun,rm -rf optionfactory-*/install-*.sh)
	$(call task,removing deps from build contexts)
	$(call irun,rm -rf optionfactory-*/deps/*)

clean-deps: FORCE
	$(call task,removing cached deps)
	$(call irun,rm -rf deps/*)

cleanup-docker-images:
	-docker images --quiet --filter=dangling=true | xargs --no-run-if-empty docker rmi
	-docker volume prune -f

#If a rule has no prerequisites or recipe, and the target of the rule is a nonexistent file,
#then make imagines this target to have been updated whenever its rule is run.
#This implies that all targets depending on this one will always have their recipe run.
FORCE:
.PHONY: sync deps docker-images clean clean-deps

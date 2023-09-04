#we user squash here to remove unwanted layers, which is an experimental feature
#{"experimental": true} > /etc/docker/daemon.json
DOCKER_BUILD_OPTIONS=--no-cache=false --squash
TAG_VERSION=52

#software versions
JDK11_VERSION=11.0.20.1
JDK11_BUILD=1
JDK17_VERSION=17.0.8
JDK17_BUILD=7
JDK21_VERSION=21
JDK21_BUILD=25
JDK21_NIGHTLY_BUILD=2023-06-08-06-27

SONARQUBE9_VERSION=9.9.0.65466

TOMCAT9_VERSION=9.0.80
TOMCAT9_ERROR_REPORT_VALVE_VERSION=2.0
TOMCAT10_VERSION=10.1.13
TOMCAT10_ERROR_REPORT_VALVE_VERSION=2.0
GOSU1_VERSION=1.14
GOLANG1_VERSION=1.20.7
LEGOPFA_VERSION=1.2
KEYCLOAK2_VERSION=21.1.1
KEYCLOAK_OPFA_MODULES_VERSION=3.9
MAVEN3_VERSION=3.9.4
CADDY2_VERSION=2.7.4

NGINX_REMOVE_SERVER_HEADER_MODULE_VERSION=1.0-1.22.1
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

docker-push-github:
	$(call task,logging in to ghcr.io)
	$(eval github_user=$(shell echo url=https://github.com/optionfactory | git credential fill | grep '^username=' | sed 's/username=//'))
	$(eval github_token=$(shell echo url=https://github.com/optionfactory | git credential fill | grep '^password=' | sed 's/password=//'))
	$(call irun,echo ${github_token} | docker login ghcr.io -u ${github_user} --password-stdin)
	$(call task,creating ghcr.io image tags: ${TAG_VERSION})
	$(call irun,docker images --filter="reference=optionfactory/*:${TAG_VERSION}" --format='{{.Repository}}' | sort | uniq |  xargs -I'{}' docker tag {}:${TAG_VERSION} ghcr.io/{}:${TAG_VERSION})
	$(call task,creating ghcr.io image tags: latest)
	$(call irun,docker images --filter="reference=optionfactory/*:${TAG_VERSION}" --format='{{.Repository}}' | sort | uniq |  xargs -I'{}' docker tag {}:${TAG_VERSION} ghcr.io/{}:latest)
	$(call task,pushing tag: ${TAG_VERSION})
	$(call irun,docker images --filter="reference=optionfactory/*:${TAG_VERSION}" --format='{{.Repository}}' | sort | uniq |  xargs -I'{}' docker push ghcr.io/{}:${TAG_VERSION})
	$(call task,pushing tag: latest)
	$(call irun,docker images --filter="reference=optionfactory/*:${TAG_VERSION}" --format='{{.Repository}}' | sort | uniq |  xargs -I'{}' docker push ghcr.io/{}:latest)


docker-optionfactory-debian11: sync-tools
docker-optionfactory-ubuntu22: sync-tools
docker-optionfactory-rocky9: sync-tools
docker-optionfactory-archlinux23: sync-tools

#docker-optionfactory-%-jdk11: $(subst -jdk11,,$@)
docker-optionfactory-debian11-jdk11: sync-jdk11 docker-optionfactory-debian11
docker-optionfactory-ubuntu22-jdk11: sync-jdk11 docker-optionfactory-ubuntu22
docker-optionfactory-rocky9-jdk11: sync-jdk11 docker-optionfactory-rocky9

#docker-optionfactory-%-jdk17: $(subst -jdk17,,$@)
docker-optionfactory-debian11-jdk17: sync-jdk17 docker-optionfactory-debian11
docker-optionfactory-ubuntu22-jdk17: sync-jdk17 docker-optionfactory-ubuntu22
docker-optionfactory-rocky9-jdk17: sync-jdk17 docker-optionfactory-rocky9

#docker-optionfactory-%-jdk21: $(subst -jdk21,,$@)
docker-optionfactory-debian11-jdk21: sync-jdk21 docker-optionfactory-debian11
docker-optionfactory-ubuntu22-jdk21: sync-jdk21 docker-optionfactory-ubuntu22
docker-optionfactory-rocky9-jdk21: sync-jdk21 docker-optionfactory-rocky9

#docker-optionfactory-%-jdk17-sonarqube9: $(subst -jdk17-sonarqube9,,$@)
docker-optionfactory-debian11-jdk17-sonarqube9: sync-sonarqube9 docker-optionfactory-debian11-jdk17
docker-optionfactory-ubuntu22-jdk17-sonarqube9: sync-sonarqube9 docker-optionfactory-ubuntu22-jdk17
docker-optionfactory-rocky9-jdk17-sonarqube9: sync-sonarqube9 docker-optionfactory-rocky9F-jdk17

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

#docker-optionfactory-%-caddy2: $(subst -caddy2,,$@)
docker-optionfactory-debian11-caddy2: sync-caddy2 docker-optionfactory-debian11
docker-optionfactory-ubuntu22-caddy2: sync-caddy2 docker-optionfactory-ubuntu22
docker-optionfactory-rocky9-caddy2: sync-caddy2 docker-optionfactory-rocky9

#docker-optionfactory-%-mariadb10: $(subst -mariadb10,,$@)
docker-optionfactory-debian11-mariadb10: sync-mariadb10 docker-optionfactory-debian11
docker-optionfactory-ubuntu22-mariadb10: sync-mariadb10 docker-optionfactory-ubuntu22
docker-optionfactory-rocky9-mariadb10: sync-mariadb10 docker-optionfactory-rocky9

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

#docker-optionfactory-%-journal-remote: $(subst -journal-remote,,$@)
docker-optionfactory-debian11-journal-remote: sync-journal-remote docker-optionfactory-debian11
docker-optionfactory-ubuntu22-journal-remote: sync-journal-remote docker-optionfactory-ubuntu22
docker-optionfactory-rocky9-journal-remote: sync-journal-remote docker-optionfactory-rocky9
docker-optionfactory-archlinux23-journal-remote: sync-journal-remote docker-optionfactory-archlinux23

#docker-optionfactory-%-jdk11-tomcat9: $(subst -tomcat9,,$@)
docker-optionfactory-debian11-jdk11-tomcat9: sync-tomcat9 docker-optionfactory-debian11-jdk11
docker-optionfactory-ubuntu22-jdk11-tomcat9: sync-tomcat9 docker-optionfactory-ubuntu22-jdk11
docker-optionfactory-rocky9-jdk11-tomcat9: sync-tomcat9 docker-optionfactory-rocky9-jdk11

#docker-optionfactory-%-jdk17-tomcat9: $(subst -tomcat9,,$@)
docker-optionfactory-debian11-jdk17-tomcat9: sync-tomcat9 docker-optionfactory-debian11-jdk17
docker-optionfactory-ubuntu22-jdk17-tomcat9: sync-tomcat9 docker-optionfactory-ubuntu22-jdk17
docker-optionfactory-rocky9-jdk17-tomcat9: sync-tomcat9 docker-optionfactory-rocky9-jdk17

#docker-optionfactory-%-jdk21-tomcat9: $(subst -tomcat9,,$@)
docker-optionfactory-debian11-jdk21-tomcat9: sync-tomcat9 docker-optionfactory-debian11-jdk21
docker-optionfactory-ubuntu22-jdk21-tomcat9: sync-tomcat9 docker-optionfactory-ubuntu22-jdk21
docker-optionfactory-rocky9-jdk21-tomcat9: sync-tomcat9 docker-optionfactory-rocky9-jdk21

#docker-optionfactory-%-jdk21-tomcat10: $(subst -tomcat9,,$@)
docker-optionfactory-debian11-jdk21-tomcat10: sync-tomcat10 docker-optionfactory-debian11-jdk21
docker-optionfactory-ubuntu22-jdk21-tomcat10: sync-tomcat10 docker-optionfactory-ubuntu22-jdk21
docker-optionfactory-rocky9-jdk21-tomcat10: sync-tomcat10 docker-optionfactory-rocky9-jdk21


#docker-optionfactory-%-jdk17-keycloak2: $(subst -keycloak2,,$@)
docker-optionfactory-debian11-jdk17-keycloak2: sync-keycloak2 docker-optionfactory-debian11-jdk17
docker-optionfactory-ubuntu22-jdk17-keycloak2: sync-keycloak2 docker-optionfactory-ubuntu22-jdk17
docker-optionfactory-rocky9-jdk17-keycloak2: sync-keycloak2 docker-optionfactory-rocky9-jdk17



docker-optionfactory-%:
	$(call task,building $@)
	$(eval name=$(subst docker-optionfactory-,,$@))
	$(call irun,docker build ${DOCKER_BUILD_OPTIONS} --tag=optionfactory/$(name):${TAG_VERSION} optionfactory-$(name))
	$(call irun,docker tag optionfactory/$(name):${TAG_VERSION} optionfactory/$(name):latest)

sync: sync-base-images sync-tools sync-jdk11 sync-jdk17 sync-jdk21 sync-sonarqube9 sync-builder sync-tomcat9 sync-tomcat10 sync-keycloak2 sync-nginx120 sync-mariadb10 sync-postgres sync-barman2 sync-journal-remote sync-golang1

sync-base-images:
	$(call task,updating base images)
	$(call irun,docker pull debian:bullseye)
	$(call irun,docker pull rockylinux/rockylinux:9)
	$(call irun,docker pull ubuntu:22.04)
	$(call irun,docker pull archlinux:latest)

sync-tools: deps/gosu1 
	$(call task,syncing gosu)
	$(call irun,echo optionfactory-rocky9/deps optionfactory-debian11/deps optionfactory-ubuntu22/deps optionfactory-archlinux23/deps | xargs -n 1 rsync -az deps/gosu-${GOSU1_VERSION})
	$(call task,syncing ps1)
	$(call irun,echo optionfactory-rocky9/deps optionfactory-debian11/deps optionfactory-ubuntu22/deps optionfactory-archlinux23/deps | xargs -n 1 rsync -az install-ps1.sh)
sync-jdk11: deps/jdk11
	$(call task,syncing jdk 11)
	$(call irun,echo optionfactory-*-jdk11/deps | xargs -n 1 rsync -az install-jdk.sh)
	$(call irun,echo optionfactory-*-jdk11/deps | xargs -n 1 rsync -az deps/jdk-${JDK11_VERSION}+${JDK11_BUILD})
sync-jdk17: deps/jdk17
	$(call task,syncing jdk 17)
	$(call irun,echo optionfactory-*-jdk17/deps | xargs -n 1 rsync -az install-jdk.sh)
	$(call irun,echo optionfactory-*-jdk17/deps | xargs -n 1 rsync -az deps/jdk-${JDK17_VERSION}+${JDK17_BUILD})
sync-jdk21: deps/jdk21
	$(call task,syncing jdk 21)
	$(call irun,echo optionfactory-*-jdk21/deps | xargs -n 1 rsync -az install-jdk.sh)
	$(call irun,echo optionfactory-*-jdk21/deps | xargs -n 1 rsync -az deps/jdk-${JDK21_VERSION}+${JDK21_BUILD})
sync-sonarqube9: deps/sonarqube9
	$(call task,syncing sonarqube 9)
	$(call irun,echo optionfactory-*-jdk*-sonarqube9/deps | xargs -n 1 rsync -az install-sonarqube9.sh)
	$(call irun,echo optionfactory-*-jdk*-sonarqube9/deps | xargs -n 1 rsync -az init-sonarqube9.sh)
	$(call irun,echo optionfactory-*-jdk*-sonarqube9/deps | xargs -n 1 rsync -az deps/sonarqube-${SONARQUBE9_VERSION})
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
sync-keycloak2: deps/keycloak2
	$(call task,syncing keycloak 2x)
	$(call irun,echo optionfactory-*-keycloak2/deps | xargs -n 1 rsync -az install-keycloak2.sh)
	$(call irun,echo optionfactory-*-keycloak2/deps | xargs -n 1 rsync -az init-keycloak2.sh)
	$(call irun,echo optionfactory-*-keycloak2/deps | xargs -n 1 rsync -az deps/keycloak-${KEYCLOAK2_VERSION})
	$(call irun,echo optionfactory-*-keycloak2/deps | xargs -n 1 rsync -az deps/optionfactory-keycloak-${KEYCLOAK_OPFA_MODULES_VERSION})
sync-nginx120: deps/nginx_remove_server_header_module deps/legopfa1
	$(call task,syncing nginx)
	$(call irun,echo optionfactory-*-nginx120/deps | xargs -n 1 rsync -az install-nginx120.sh)
	$(call irun,echo optionfactory-*-nginx120/deps | xargs -n 1 rsync -az init-nginx120.sh)
	$(call irun,echo optionfactory-*-nginx120/deps | xargs -n 1 rsync -az deps/opfa_http_remove_server_header_module-${NGINX_REMOVE_SERVER_HEADER_MODULE_VERSION}.so)
	$(call irun,echo optionfactory-*-nginx120/deps | xargs -n 1 rsync -az deps/legopfa-${LEGOPFA_VERSION})
sync-caddy2: deps/caddy2
	$(call task,syncing caddy 2)
	$(call irun,echo optionfactory-*-caddy2/deps | xargs -n 1 rsync -az install-caddy2.sh)
	$(call irun,echo optionfactory-*-caddy2/deps | xargs -n 1 rsync -az init-caddy2.sh)
	$(call irun,echo optionfactory-*-caddy2/deps | xargs -n 1 rsync -az deps/caddy-${CADDY2_VERSION})
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
sync-journal-remote:
	$(call task,syncing journal-remote)
	$(call irun,echo optionfactory-*-journal-remote/deps | xargs -n 1 rsync -az install-journal-remote.sh)
	$(call irun,echo optionfactory-*-journal-remote/deps | xargs -n 1 rsync -az init-journal-remote.sh)
sync-golang1: deps/golang1
	$(call task,syncing golang)
	$(call irun,echo optionfactory-*-golang1/deps | xargs -n 1 rsync -az install-golang1.sh)
	$(call irun,echo optionfactory-*-golang1/deps | xargs -n 1 rsync -az deps/golang-${GOLANG1_VERSION})


deps/gosu1: deps/gosu-${GOSU1_VERSION}
deps/legopfa1: deps/legopfa-${LEGOPFA_VERSION}
deps/jdk11: deps/jdk-${JDK11_VERSION}+${JDK11_BUILD}
deps/jdk17: deps/jdk-${JDK17_VERSION}+${JDK17_BUILD}
deps/jdk21: deps/jdk-${JDK21_VERSION}+${JDK21_BUILD}
deps/maven3: deps/apache-maven-${MAVEN3_VERSION}
deps/sonarqube9: deps/sonarqube-${SONARQUBE9_VERSION}
deps/tomcat9: deps/apache-tomcat-${TOMCAT9_VERSION} deps/tomcat9-logging-error-report-valve-${TOMCAT9_ERROR_REPORT_VALVE_VERSION}.jar
deps/tomcat10: deps/apache-tomcat-${TOMCAT10_VERSION} deps/tomcat10-logging-error-report-valve-${TOMCAT10_ERROR_REPORT_VALVE_VERSION}.jar
deps/keycloak2: deps/keycloak-${KEYCLOAK2_VERSION} deps/optionfactory-keycloak-${KEYCLOAK_OPFA_MODULES_VERSION}
deps/nginx_remove_server_header_module: deps/opfa_http_remove_server_header_module-${NGINX_REMOVE_SERVER_HEADER_MODULE_VERSION}.so
deps/caddy2: deps/caddy-${CADDY2_VERSION}
deps/mariadb10:
deps/postgres:
deps/barman2:
deps/golang1: deps/golang-${GOLANG1_VERSION}/bin/go

deps/jdk-${JDK11_VERSION}+${JDK11_BUILD}:
	$(call irun,curl -# -j -k -L https://github.com/adoptium/temurin11-binaries/releases/download/jdk-${JDK11_VERSION}%2B${JDK11_BUILD}/OpenJDK11U-jdk_x64_linux_hotspot_${JDK11_VERSION}_${JDK11_BUILD}.tar.gz	| tar xz -C deps)
deps/jdk-${JDK17_VERSION}+${JDK17_BUILD}:
	$(call irun,curl -# -j -k -L https://github.com/adoptium/temurin17-binaries/releases/download/jdk-${JDK17_VERSION}%2B${JDK17_BUILD}/OpenJDK17U-jdk_x64_linux_hotspot_${JDK17_VERSION}_${JDK17_BUILD}.tar.gz	| tar xz -C deps)
deps/jdk-${JDK21_VERSION}+${JDK21_BUILD}:
	$(call irun,curl -# -j -k -L https://github.com/adoptium/temurin21-binaries/releases/download/jdk-${JDK21_NIGHTLY_BUILD}-beta/OpenJDK-jdk_x64_linux_hotspot_${JDK21_NIGHTLY_BUILD}.tar.gz | tar xz -C deps)
deps/apache-maven-${MAVEN3_VERSION}:
	$(call irun,curl -# -j -k -L https://downloads.apache.org/maven/maven-3/${MAVEN3_VERSION}/binaries/apache-maven-${MAVEN3_VERSION}-bin.tar.gz | tar xz -C deps)
deps/sonarqube-${SONARQUBE9_VERSION}:	
	$(call irun,cd deps && curl -# -sSL -k https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONARQUBE9_VERSION}.zip | jar xf /dev/stdin)
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
deps/legopfa-${LEGOPFA_VERSION}:	
	$(call irun,curl -# -j -k -L https://github.com/optionfactory/legopfa/releases/download/${LEGOPFA_VERSION}/legopfa-${LEGOPFA_VERSION} -o deps/legopfa-${LEGOPFA_VERSION})
	$(call irun,chmod +x deps/legopfa-${LEGOPFA_VERSION})
deps/golang-${GOLANG1_VERSION}/bin/go:
	$(call irun,mkdir -p deps/golang-${GOLANG1_VERSION})
	$(call irun,curl -# -j -k -L https://golang.org/dl/go${GOLANG1_VERSION}.linux-amd64.tar.gz | tar xz -C deps/golang-${GOLANG1_VERSION} --strip-components=1)
deps/keycloak-${KEYCLOAK2_VERSION}:
	$(call irun,curl -# -j -k -L  https://github.com/keycloak/keycloak/releases/download/${KEYCLOAK2_VERSION}/keycloak-${KEYCLOAK2_VERSION}.tar.gz | tar xz -C deps)
deps/optionfactory-keycloak-${KEYCLOAK_OPFA_MODULES_VERSION}:
	$(call irun,mkdir -p deps/optionfactory-keycloak-${KEYCLOAK_OPFA_MODULES_VERSION})
	$(eval modules=$(shell curl https://repo1.maven.org/maven2/net/optionfactory/keycloak/optionfactory-keycloak/${KEYCLOAK_OPFA_MODULES_VERSION}/optionfactory-keycloak-${KEYCLOAK_OPFA_MODULES_VERSION}.pom | grep '<module>' | grep -Po '(?<=>)[^<]+(?=<)'))
	$(call irun,for module in ${modules}; do curl -# -j -k -L "https://repo1.maven.org/maven2/net/optionfactory/keycloak/$${module}/${KEYCLOAK_OPFA_MODULES_VERSION}/$${module}-${KEYCLOAK_OPFA_MODULES_VERSION}.jar" > "deps/optionfactory-keycloak-${KEYCLOAK_OPFA_MODULES_VERSION}/$${module}.jar"; done)
	$(eval lpn_version=$(shell curl https://repo1.maven.org/maven2/net/optionfactory/keycloak/optionfactory-keycloak/${KEYCLOAK_OPFA_MODULES_VERSION}/optionfactory-keycloak-${KEYCLOAK_OPFA_MODULES_VERSION}.pom | grep '<libphonenumber.version>' | grep -Po '(?<=>)[^<]+(?=<)'))	
	$(call irun,curl -# -j -k -L "https://repo1.maven.org/maven2/com/googlecode/libphonenumber/libphonenumber/${lpn_version}/libphonenumber-${lpn_version}.jar" > "deps/optionfactory-keycloak-${KEYCLOAK_OPFA_MODULES_VERSION}/libphonenumber-${lpn_version}.jar")	
	$(eval hv_version=$(shell curl https://repo1.maven.org/maven2/net/optionfactory/keycloak/optionfactory-keycloak/${KEYCLOAK_OPFA_MODULES_VERSION}/optionfactory-keycloak-${KEYCLOAK_OPFA_MODULES_VERSION}.pom | grep '<hibernatevalidator.version>' | grep -Po '(?<=>)[^<]+(?=<)'))	
	$(call irun,curl -# -j -k -L "https://repo1.maven.org/maven2/org/hibernate/validator/hibernate-validator/${hv_version}/hibernate-validator-${hv_version}.jar" > "deps/optionfactory-keycloak-${KEYCLOAK_OPFA_MODULES_VERSION}/hibernate-validator-${hv_version}.jar")	
deps/opfa_http_remove_server_header_module-${NGINX_REMOVE_SERVER_HEADER_MODULE_VERSION}.so:
	$(call irun,curl -# -j -k -L  https://github.com/optionfactory/nginx-remove-server-header-module/releases/download/v1.0/opfa_http_remove_server_header_module-${NGINX_REMOVE_SERVER_HEADER_MODULE_VERSION}.so -o deps/opfa_http_remove_server_header_module-${NGINX_REMOVE_SERVER_HEADER_MODULE_VERSION}.so)
deps/caddy-${CADDY2_VERSION}:
	$(call irun,curl -# -j -k -L  "https://github.com/caddyserver/caddy/releases/download/v${CADDY2_VERSION}/caddy_${CADDY2_VERSION}_linux_amd64.tar.gz" | tar xz -C deps caddy && mv deps/caddy deps/caddy-${CADDY2_VERSION})

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

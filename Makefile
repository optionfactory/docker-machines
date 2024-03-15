#we user squash here to remove unwanted layers, which is an experimental feature
#{"experimental": true} > /etc/docker/daemon.json
DOCKER_BUILD_OPTIONS=--no-cache=false --squash
TAG_VERSION=71

#software versions

SONARQUBE9_VERSION=9.9.0.65466

TOMCAT9_VERSION=9.0.86
TOMCAT9_ERROR_REPORT_VALVE_VERSION=2.0
TOMCAT10_VERSION=10.1.19
TOMCAT10_ERROR_REPORT_VALVE_VERSION=2.0
GOSU1_VERSION=1.14
LEGOPFA_VERSION=1.2
KEYCLOAK2_VERSION=24.0.1
KEYCLOAK_OPFA_MODULES_VERSION=6.0
MAVEN3_VERSION=3.9.6
CADDY2_VERSION=2.7.6
JOURNAL_WEBD_VERSION=1.1
ETCD3_VERSION=3.5.12
NGINX_REMOVE_SERVER_HEADER_MODULE_VERSION=1.24.0-1
#/software versions

SHELL=/bin/bash

define task
	@echo -e "\033[1;32m"$(1)"\033[0m"
endef

define irun 
    @set -o pipefail; $(1) | sed 's/^/    /'
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


docker-optionfactory-debian12: sync-tools
docker-optionfactory-debian13: sync-tools
docker-optionfactory-rocky9: sync-tools


#docker-optionfactory-%-jdk17: $(subst -jdk17,,$@)
docker-optionfactory-debian12-jdk17: sync-jdk17 docker-optionfactory-debian12
docker-optionfactory-rocky9-jdk17: sync-jdk17 docker-optionfactory-rocky9

#docker-optionfactory-%-jdk21: $(subst -jdk21,,$@)
docker-optionfactory-debian12-jdk21: sync-jdk21 docker-optionfactory-debian12
docker-optionfactory-rocky9-jdk21: sync-jdk21 docker-optionfactory-rocky9

#docker-optionfactory-%-jdk17-sonarqube9: $(subst -jdk17-sonarqube9,,$@)
docker-optionfactory-debian12-jdk17-sonarqube9: sync-sonarqube9 docker-optionfactory-debian12-jdk17
docker-optionfactory-rocky9-jdk17-sonarqube9: sync-sonarqube9 docker-optionfactory-rocky9-jdk17

#docker-optionfactory-%-jdk17-builder: $(subst -jdk17-builder,,$@)
docker-optionfactory-debian12-jdk17-builder: sync-builder docker-optionfactory-debian12-jdk17
docker-optionfactory-rocky9-jdk17-builder: sync-builder docker-optionfactory-rocky9-jdk17

#docker-optionfactory-%-jdk21-builder: $(subst -jdk21-builder,,$@)
docker-optionfactory-debian12-jdk21-builder: sync-builder docker-optionfactory-debian12-jdk21

#docker-optionfactory-%-nginx120: $(subst -nginx120,,$@)
docker-optionfactory-debian12-nginx120: sync-nginx120 docker-optionfactory-debian12
docker-optionfactory-rocky9-nginx120: sync-nginx120 docker-optionfactory-rocky9

#docker-optionfactory-%-caddy2: $(subst -caddy2,,$@)
docker-optionfactory-debian12-caddy2: sync-caddy2 docker-optionfactory-debian12
docker-optionfactory-rocky9-caddy2: sync-caddy2 docker-optionfactory-rocky9

#docker-optionfactory-%-mariadb10: $(subst -mariadb10,,$@)
docker-optionfactory-debian12-mariadb10: sync-mariadb10 docker-optionfactory-debian12
docker-optionfactory-rocky9-mariadb10: sync-mariadb10 docker-optionfactory-rocky9

#docker-optionfactory-%-postgres15: $(subst -postgres15,,$@)
docker-optionfactory-debian12-postgres15: sync-postgres docker-optionfactory-debian12
docker-optionfactory-rocky9-postgres15: sync-postgres docker-optionfactory-rocky9

#docker-optionfactory-%-postgres16: $(subst -postgres15,,$@)
docker-optionfactory-debian12-postgres16: sync-postgres docker-optionfactory-debian12
docker-optionfactory-rocky9-postgres16: sync-postgres docker-optionfactory-rocky9

#docker-optionfactory-%-etcd3: $(subst -etcd3,,$@)
docker-optionfactory-debian12-etcd3: sync-etcd3 docker-optionfactory-debian12

#docker-optionfactory-%-barman2: $(subst -barman2,,$@)
docker-optionfactory-debian12-barman2: sync-barman2 docker-optionfactory-debian12

#docker-optionfactory-%-journal-webd: $(subst -journal-webd,,$@)
docker-optionfactory-debian12-journal-webd: sync-journal-webd docker-optionfactory-debian12
docker-optionfactory-debian13-journal-webd: sync-journal-webd docker-optionfactory-debian13

#docker-optionfactory-%-jdk17-tomcat9: $(subst -tomcat9,,$@)
docker-optionfactory-debian12-jdk17-tomcat9: sync-tomcat9 docker-optionfactory-debian12-jdk17
docker-optionfactory-rocky9-jdk17-tomcat9: sync-tomcat9 docker-optionfactory-rocky9-jdk17

#docker-optionfactory-%-jdk21-tomcat9: $(subst -tomcat9,,$@)
docker-optionfactory-debian12-jdk21-tomcat9: sync-tomcat9 docker-optionfactory-debian12-jdk21
docker-optionfactory-rocky9-jdk21-tomcat9: sync-tomcat9 docker-optionfactory-rocky9-jdk21


#docker-optionfactory-%-jdk21-tomcat10: $(subst -tomcat9,,$@)
docker-optionfactory-debian12-jdk21-tomcat10: sync-tomcat10 docker-optionfactory-debian12-jdk21
docker-optionfactory-rocky9-jdk21-tomcat10: sync-tomcat10 docker-optionfactory-rocky9-jdk21


#docker-optionfactory-%-jdk17-keycloak2: $(subst -keycloak2,,$@)
docker-optionfactory-debian12-jdk17-keycloak2: sync-keycloak2 docker-optionfactory-debian12-jdk17
docker-optionfactory-rocky9-jdk17-keycloak2: sync-keycloak2 docker-optionfactory-rocky9-jdk17

#docker-optionfactory-%-jdk21-keycloak2: $(subst -keycloak2,,$@)
docker-optionfactory-debian12-jdk21-keycloak2: sync-keycloak2 docker-optionfactory-debian12-jdk21
docker-optionfactory-rocky9-jdk21-keycloak2: sync-keycloak2 docker-optionfactory-rocky9-jdk21



docker-optionfactory-%:
	$(call task,building $@)
	$(eval name=$(subst docker-optionfactory-,,$@))
	$(call irun,docker build ${DOCKER_BUILD_OPTIONS} --tag=optionfactory/$(name):${TAG_VERSION} optionfactory-$(name))
	$(call irun,docker tag optionfactory/$(name):${TAG_VERSION} optionfactory/$(name):latest)

sync: sync-base-images sync-tools sync-jdk17 sync-jdk21 sync-sonarqube9 sync-builder sync-tomcat9 sync-tomcat10 sync-keycloak2 sync-nginx120 sync-mariadb10 sync-postgres sync-barman2 sync-journal-webd

sync-base-images:
	$(call task,updating base images)
	$(call irun,docker pull debian:bullseye)
	$(call irun,docker pull debian:bookworm)
	$(call irun,docker pull debian:trixie)
	$(call irun,docker pull rockylinux/rockylinux:9)

sync-tools: deps/gosu1 
	$(call task,syncing gosu)
	$(call irun,echo optionfactory-rocky9/deps optionfactory-debian12/deps optionfactory-debian13/deps | xargs -n 1 rsync -az deps/gosu-${GOSU1_VERSION})
	$(call task,syncing ps1)
	$(call irun,echo optionfactory-rocky9/deps optionfactory-debian12/deps optionfactory-debian13/deps | xargs -n 1 rsync -az install-ps1.sh)
sync-jdk17: deps/jdk17
	$(call task,syncing jdk 17)
	$(call irun,echo optionfactory-*-jdk17/deps | xargs -n 1 rsync -az install-jdk.sh)
	$(call irun,echo optionfactory-*-jdk17/deps | xargs -n 1 rsync -az deps/amazon-corretto-17.*)
sync-jdk21: deps/jdk21
	$(call task,syncing jdk 21)
	$(call irun,echo optionfactory-*-jdk21/deps | xargs -n 1 rsync -az install-jdk.sh)
	$(call irun,echo optionfactory-*-jdk21/deps | xargs -n 1 rsync -az deps/amazon-corretto-21.*)
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
sync-etcd3: deps/etcd3
	$(call task,syncing etcd3)
	$(call irun,echo optionfactory-*-etcd3/deps | xargs -n 1 rsync -az install-etcd3.sh)
	$(call irun,echo optionfactory-*-etcd3/deps | xargs -n 1 rsync -az init-etcd3.sh)
	$(call irun,echo optionfactory-*-etcd3/deps | xargs -n 1 rsync -az deps/etcd-v${ETCD3_VERSION}-linux-amd64)
sync-barman2: deps/barman2
	$(call task,syncing barman2)
	$(call irun,echo optionfactory-*-barman2/deps | xargs -n 1 rsync -az install-barman2.sh)
	$(call irun,echo optionfactory-*-barman2/deps | xargs -n 1 rsync -az init-barman2.sh)
sync-journal-webd: deps/journal-webd
	$(call task,syncing journal-webd)
	$(call irun,echo optionfactory-*-journal-webd/deps | xargs -n 1 rsync -az install-journal-webd.sh)
	$(call irun,echo optionfactory-*-journal-webd/deps | xargs -n 1 rsync -az deps/journal-webd-${JOURNAL_WEBD_VERSION})


deps/gosu1: deps/gosu-${GOSU1_VERSION}
deps/legopfa1: deps/legopfa-${LEGOPFA_VERSION}
deps/maven3: deps/apache-maven-${MAVEN3_VERSION}
deps/sonarqube9: deps/sonarqube-${SONARQUBE9_VERSION}
deps/tomcat9: deps/apache-tomcat-${TOMCAT9_VERSION} deps/tomcat9-logging-error-report-valve-${TOMCAT9_ERROR_REPORT_VALVE_VERSION}.jar
deps/tomcat10: deps/apache-tomcat-${TOMCAT10_VERSION} deps/tomcat10-logging-error-report-valve-${TOMCAT10_ERROR_REPORT_VALVE_VERSION}.jar
deps/keycloak2: deps/keycloak-${KEYCLOAK2_VERSION} deps/optionfactory-keycloak-${KEYCLOAK_OPFA_MODULES_VERSION}
deps/nginx_remove_server_header_module: deps/opfa_http_remove_server_header_module-${NGINX_REMOVE_SERVER_HEADER_MODULE_VERSION}.so
deps/caddy2: deps/caddy-${CADDY2_VERSION}
deps/mariadb10:
deps/postgres:
deps/etcd3: deps/ectd-v${ETCD3_VERSION}-linux-amd64
deps/barman2:
deps/journal-webd: deps/journal-webd-${JOURNAL_WEBD_VERSION}

deps/jdk17:
	$(call irun,curl -# -j -k -L https://corretto.aws/downloads/latest/amazon-corretto-17-x64-linux-jdk.tar.gz | tar xz -C deps)
deps/jdk21:
	$(call irun,curl -# -j -k -L https://corretto.aws/downloads/latest/amazon-corretto-21-x64-linux-jdk.tar.gz | tar xz -C deps)
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
	$(call irun,curl -# -j -k -L  https://github.com/optionfactory/nginx-remove-server-header-module/releases/download/v${NGINX_REMOVE_SERVER_HEADER_MODULE_VERSION}/opfa_http_remove_server_header_module-${NGINX_REMOVE_SERVER_HEADER_MODULE_VERSION}.so -o deps/opfa_http_remove_server_header_module-${NGINX_REMOVE_SERVER_HEADER_MODULE_VERSION}.so)
deps/caddy-${CADDY2_VERSION}:
	$(call irun,curl -# -j -k -L  "https://github.com/caddyserver/caddy/releases/download/v${CADDY2_VERSION}/caddy_${CADDY2_VERSION}_linux_amd64.tar.gz" | tar xz -C deps caddy && mv deps/caddy deps/caddy-${CADDY2_VERSION})
deps/ectd-v${ETCD3_VERSION}-linux-amd64:
	$(call irun,curl -# -j -k -L  "https://github.com/etcd-io/etcd/releases/download/v${ETCD3_VERSION}/etcd-v${ETCD3_VERSION}-linux-amd64.tar.gz" | tar xz -C deps)		
deps/journal-webd-${JOURNAL_WEBD_VERSION}:
	$(call irun,curl -# -j -k -L  "https://github.com/optionfactory/journal-webd/releases/download/${JOURNAL_WEBD_VERSION}/journal-webd-${JOURNAL_WEBD_VERSION}" -o deps/journal-webd-${JOURNAL_WEBD_VERSION})

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

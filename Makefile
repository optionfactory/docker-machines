DOCKER_BUILD_OPTIONS=--no-cache=false --progress=auto
TAG_VERSION=201

#software versions

SONARQUBE10_VERSION=25.8.0.112029

TOMCAT9_VERSION=9.0.108
TOMCAT9_ERROR_REPORT_VALVE_VERSION=2.0
TOMCAT10_VERSION=10.1.44
TOMCAT10_ERROR_REPORT_VALVE_VERSION=2.0
TOMCAT11_VERSION=11.0.10
TOMCAT11_ERROR_REPORT_VALVE_VERSION=2.0
GOSU1_VERSION=1.17
LEGOPFA_VERSION=1.3
KEYCLOAK2_VERSION=26.3.3
KEYCLOAK_OPFA_MODULES_VERSION=8.4
MAVEN3_VERSION=3.9.11
CADDY2_VERSION=2.10.2
JOURNAL_WEBD_VERSION=1.1
ETCD3_VERSION=3.6.4
NGINX_MAJOR_VERSION=1.28
NGINX_REMOVE_SERVER_HEADER_MODULE_VERSION=1.28.0-1

GRAFANA_VERSION=12.1.1
TEMPO_VERSION=2.8.2
PROMETHEUS_VERSION=3.5.0
ALERTMANAGER_VERSION=0.28.1
NODE_EXPORTER_VERSION=1.9.1
CADVISOR_VERSION=0.53.0
POSTGRES_EXPORTER_VERSION=0.17.1

NGINX_EXPORTER_VERSION=1.4.2
#/software versions

SHELL=/bin/bash -o pipefail

define task
	@echo -e "\033[1;32m"$(1)"\033[0m"
endef

define irun 
   @$(1) | sed 's/^/    /'
endef


help:
	@echo usage: make [clean-deps] [clean] sync docker-images
	@echo usage: make [clean-deps] [clean] docker-optionfactory-debian13-mariadb10
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


docker-optionfactory-debian13: sync-tools


#docker-optionfactory-%-medic: $(subst -jdk21,,$@)
docker-optionfactory-debian13-medic: sync-medic docker-optionfactory-debian13


#docker-optionfactory-%-jdk21: $(subst -jdk21,,$@)
docker-optionfactory-debian13-jdk21: sync-jdk21 docker-optionfactory-debian13
docker-optionfactory-debian13-jdk25: sync-jdk25 docker-optionfactory-debian13

#docker-optionfactory-%-jdk21-sonarqube10: $(subst -jdk21-sonarqube10,,$@)
docker-optionfactory-debian13-jdk21-sonarqube10: sync-sonarqube10 docker-optionfactory-debian13-jdk21
docker-optionfactory-debian13-jdk25-sonarqube10: sync-sonarqube10 docker-optionfactory-debian13-jdk25

#docker-optionfactory-%-jdk21-builder: $(subst -jdk21-builder,,$@)
docker-optionfactory-debian13-jdk21-builder: sync-builder docker-optionfactory-debian13-jdk21
docker-optionfactory-debian13-jdk25-builder: sync-builder docker-optionfactory-debian13-jdk25

#docker-optionfactory-%-nginx120: $(subst -nginx120,,$@)
docker-optionfactory-debian13-nginx120: sync-nginx120 docker-optionfactory-debian13
docker-optionfactory-debian13-nginx120: BUILD_ARGS+=--build-arg NGINX_MAJOR_VERSION=$(NGINX_MAJOR_VERSION)

#docker-optionfactory-%-caddy2: $(subst -caddy2,,$@)
docker-optionfactory-debian13-caddy2: sync-caddy2 docker-optionfactory-debian13

#docker-optionfactory-%-mariadb12: $(subst -mariadb10,,$@)
docker-optionfactory-debian13-mariadb12: sync-mariadb12 docker-optionfactory-debian13

#docker-optionfactory-%-postgres15: $(subst -postgres15,,$@)
docker-optionfactory-debian13-postgres15: sync-postgres docker-optionfactory-debian13
docker-optionfactory-debian13-postgres15: BUILD_ARGS+=--build-arg PSQL_MAJOR_VERSION=15

#docker-optionfactory-%-postgres16: $(subst -postgres16,,$@)
docker-optionfactory-debian13-postgres16: sync-postgres docker-optionfactory-debian13
docker-optionfactory-debian13-postgres16: BUILD_ARGS+=--build-arg PSQL_MAJOR_VERSION=16

#docker-optionfactory-%-postgres17: $(subst -postgres17,,$@)
docker-optionfactory-debian13-postgres17: sync-postgres docker-optionfactory-debian13
docker-optionfactory-debian13-postgres17: BUILD_ARGS+=--build-arg PSQL_MAJOR_VERSION=17

#docker-optionfactory-%-etcd3: $(subst -etcd3,,$@)
docker-optionfactory-debian13-etcd3: sync-etcd3 docker-optionfactory-debian13

#docker-optionfactory-%-barman2: $(subst -barman2,,$@)
docker-optionfactory-debian13-barman2: sync-barman2 docker-optionfactory-debian13

#docker-optionfactory-%-journal-webd: $(subst -journal-webd,,$@)
docker-optionfactory-debian13-journal-webd: sync-journal-webd docker-optionfactory-debian13

#docker-optionfactory-%-jdk21-tomcat9: $(subst -tomcat9,,$@)
docker-optionfactory-debian13-jdk21-tomcat9: sync-tomcat9 docker-optionfactory-debian13-jdk21
docker-optionfactory-debian13-jdk21-tomcat9: BUILD_ARGS+=--build-arg TOMCAT_MAJOR_VERSION=9

docker-optionfactory-debian13-jdk25-tomcat9: sync-tomcat9 docker-optionfactory-debian13-jdk25
docker-optionfactory-debian13-jdk25-tomcat9: BUILD_ARGS+=--build-arg TOMCAT_MAJOR_VERSION=9

#docker-optionfactory-%-jdk21-tomcat10: $(subst -tomcat10,,$@)
docker-optionfactory-debian13-jdk21-tomcat10: sync-tomcat10 docker-optionfactory-debian13-jdk21
docker-optionfactory-debian13-jdk21-tomcat10: BUILD_ARGS+=--build-arg TOMCAT_MAJOR_VERSION=10

docker-optionfactory-debian13-jdk25-tomcat10: sync-tomcat10 docker-optionfactory-debian13-jdk25
docker-optionfactory-debian13-jdk25-tomcat10: BUILD_ARGS+=--build-arg TOMCAT_MAJOR_VERSION=10


#docker-optionfactory-%-jdk21-tomcat10: $(subst -tomcat11,,$@)
docker-optionfactory-debian13-jdk21-tomcat11: sync-tomcat11 docker-optionfactory-debian13-jdk21
docker-optionfactory-debian13-jdk21-tomcat11: BUILD_ARGS+=--build-arg TOMCAT_MAJOR_VERSION=11

docker-optionfactory-debian13-jdk25-tomcat11: sync-tomcat11 docker-optionfactory-debian13-jdk25
docker-optionfactory-debian13-jdk25-tomcat11: BUILD_ARGS+=--build-arg TOMCAT_MAJOR_VERSION=11

#docker-optionfactory-%-jdk21-keycloak2: $(subst -keycloak2,,$@)
docker-optionfactory-debian13-jdk21-keycloak2: sync-keycloak2 docker-optionfactory-debian13-jdk21

#docker-optionfactory-%-monitoring-prometheus: $(subst -monitoring-prometheus,,$@)
docker-optionfactory-debian13-monitoring-prometheus: sync-monitoring-prometheus docker-optionfactory-debian13

#docker-optionfactory-%-monitoring-alertmanager: $(subst -monitoring-alertmanager,,$@)
docker-optionfactory-debian13-monitoring-alertmanager: sync-monitoring-alertmanager docker-optionfactory-debian13

#docker-optionfactory-%-monitoring-grafana: $(subst -monitoring-alertmanager,,$@)
docker-optionfactory-debian13-monitoring-grafana: sync-monitoring-grafana docker-optionfactory-debian13

#docker-optionfactory-%-monitoring-cadvisor: $(subst -monitoring-cadvisor,,$@)
docker-optionfactory-debian13-monitoring-cadvisor: sync-monitoring-cadvisor docker-optionfactory-debian13

#docker-optionfactory-%-monitoring-postgres: $(subst -monitoring-postgres,,$@)
docker-optionfactory-debian13-monitoring-postgres: sync-monitoring-postgres docker-optionfactory-debian13

#docker-optionfactory-%-monitoring-nginx: $(subst -monitoring-nginx,,$@)
docker-optionfactory-debian13-monitoring-nginx: sync-monitoring-nginx docker-optionfactory-debian13

#docker-optionfactory-%-monitoring-host: $(subst -monitoring-host,,$@)
docker-optionfactory-debian13-monitoring-host: sync-monitoring-host docker-optionfactory-debian13

#docker-optionfactory-%-monitoring-tempo: $(subst -monitoring-tempo,,$@)
docker-optionfactory-debian13-monitoring-tempo: sync-monitoring-tempo docker-optionfactory-debian13


docker-optionfactory-%:
	$(call task,building $@)
	$(eval name=$(subst docker-optionfactory-,,$@))
	$(call irun,docker build ${DOCKER_BUILD_OPTIONS} $(BUILD_ARGS) --tag=optionfactory/$(name):${TAG_VERSION} --tag=optionfactory/$(name):latest optionfactory-$(name))

sync-base-images:
	$(call task,updating base images)
	$(call irun,docker pull debian:bookworm)
	$(call irun,docker pull debian:trixie)

sync-medic:
	$(call task,syncing medic)
	$(call irun,echo optionfactory-*-medic/deps | xargs -n 1 rsync -az install-medic.sh)

sync-tools: deps/gosu1 
	$(call task,syncing gosu)
	$(call irun,echo optionfactory-debian13/deps | xargs -n 1 rsync -az deps/gosu-${GOSU1_VERSION})
	$(call task,syncing ps1)
	$(call irun,echo optionfactory-debian13/deps | xargs -n 1 rsync -az install-ps1.sh)
	$(call task,syncing base image)
	$(call irun,echo optionfactory-debian13/deps | xargs -n 1 rsync -az install-base-image.sh)
sync-jdk21: deps/jdk21
	$(call task,syncing jdk 21)
	$(call irun,echo optionfactory-*-jdk21/deps | xargs -n 1 rsync -az install-jdk.sh)
	$(call irun,echo optionfactory-*-jdk21/deps | xargs -n 1 rsync -az deps/amazon-corretto-21.*)
sync-jdk25: deps/jdk25
	$(call task,syncing jdk 25)
	$(call irun,echo optionfactory-*-jdk25/deps | xargs -n 1 rsync -az install-jdk.sh)
	$(call irun,echo optionfactory-*-jdk25/deps | xargs -n 1 rsync -az deps/amazon-corretto-25.*)
sync-sonarqube10: deps/sonarqube10
	$(call task,syncing sonarqube 10)
	$(call irun,echo optionfactory-*-jdk*-sonarqube10/deps | xargs -n 1 rsync -az install-sonarqube.sh)
	$(call irun,echo optionfactory-*-jdk*-sonarqube10/deps | xargs -n 1 rsync -az deps/sonarqube-${SONARQUBE10_VERSION})
sync-builder: deps/maven3
	$(call task,syncing maven 3)
	$(call irun,echo optionfactory-*-jdk*-builder/deps | xargs -n 1 rsync -az install-builder.sh)
	$(call irun,echo optionfactory-*-jdk*-builder/deps | xargs -n 1 rsync -az deps/apache-maven-${MAVEN3_VERSION})
sync-tomcat9: deps/tomcat9
	$(call task,syncing tomcat 9)
	$(call irun,echo optionfactory-*-tomcat9/deps | xargs -n 1 rsync -az install-tomcat.sh)
	$(call irun,echo optionfactory-*-tomcat9/deps | xargs -n 1 rsync -az deps/apache-tomcat-${TOMCAT9_VERSION})
	$(call irun,echo optionfactory-*-tomcat9/deps | xargs -n 1 rsync -az deps/tomcat9-logging-error-report-valve-${TOMCAT9_ERROR_REPORT_VALVE_VERSION}.jar)
sync-tomcat10: deps/tomcat10
	$(call task,syncing tomcat 10)
	$(call irun,echo optionfactory-*-tomcat10/deps | xargs -n 1 rsync -az install-tomcat.sh)
	$(call irun,echo optionfactory-*-tomcat10/deps | xargs -n 1 rsync -az deps/apache-tomcat-${TOMCAT10_VERSION})
	$(call irun,echo optionfactory-*-tomcat10/deps | xargs -n 1 rsync -az deps/tomcat10-logging-error-report-valve-${TOMCAT10_ERROR_REPORT_VALVE_VERSION}.jar)
sync-tomcat11: deps/tomcat11
	$(call task,syncing tomcat 11)
	$(call irun,echo optionfactory-*-tomcat11/deps | xargs -n 1 rsync -az install-tomcat.sh)
	$(call irun,echo optionfactory-*-tomcat11/deps | xargs -n 1 rsync -az deps/apache-tomcat-${TOMCAT11_VERSION})
	$(call irun,echo optionfactory-*-tomcat11/deps | xargs -n 1 rsync -az deps/tomcat11-logging-error-report-valve-${TOMCAT11_ERROR_REPORT_VALVE_VERSION}.jar)
sync-keycloak2: deps/keycloak2
	$(call task,syncing keycloak 2x)
	$(call irun,echo optionfactory-*-keycloak2/deps | xargs -n 1 rsync -az install-keycloak.sh)
	$(call irun,echo optionfactory-*-keycloak2/deps | xargs -n 1 rsync -az deps/keycloak-${KEYCLOAK2_VERSION})
	$(call irun,echo optionfactory-*-keycloak2/deps | xargs -n 1 rsync -az deps/optionfactory-keycloak-${KEYCLOAK_OPFA_MODULES_VERSION})
sync-nginx120: deps/nginx_remove_server_header_module deps/legopfa1
	$(call task,syncing nginx)
	$(call irun,echo optionfactory-*-nginx120/deps | xargs -n 1 rsync -az install-nginx.sh)
	$(call irun,echo optionfactory-*-nginx120/deps | xargs -n 1 rsync -az deps/opfa_http_remove_server_header_module-${NGINX_REMOVE_SERVER_HEADER_MODULE_VERSION}.so)
	$(call irun,echo optionfactory-*-nginx120/deps | xargs -n 1 rsync -az deps/legopfa-${LEGOPFA_VERSION})
sync-caddy2: deps/caddy2
	$(call task,syncing caddy 2)
	$(call irun,echo optionfactory-*-caddy2/deps | xargs -n 1 rsync -az install-caddy.sh)
	$(call irun,echo optionfactory-*-caddy2/deps | xargs -n 1 rsync -az deps/caddy-${CADDY2_VERSION})
sync-mariadb12: deps/mariadb12
	$(call task,syncing mariadb 10)
	$(call irun,echo optionfactory-*-mariadb12/deps | xargs -n 1 rsync -az install-mariadb.sh)
	$(call irun,echo optionfactory-*-mariadb12/deps | xargs -n 1 rsync -az init-mariadb.sh)
sync-postgres: deps/postgres
	$(call task,syncing postgres)
	$(call irun,echo optionfactory-*-postgres*/deps | xargs -n 1 rsync -az install-postgres.sh)
	$(call irun,echo optionfactory-*-postgres*/deps | xargs -n 1 rsync -az init-postgres.sh)
sync-etcd3: deps/etcd3
	$(call task,syncing etcd3)
	$(call irun,echo optionfactory-*-etcd3/deps | xargs -n 1 rsync -az install-etcd.sh)
	$(call irun,echo optionfactory-*-etcd3/deps | xargs -n 1 rsync -az deps/etcd-v${ETCD3_VERSION}-linux-amd64)
sync-barman2: deps/barman2
	$(call task,syncing barman2)
	$(call irun,echo optionfactory-*-barman2/deps | xargs -n 1 rsync -az install-barman.sh)
sync-journal-webd: deps/journal-webd
	$(call task,syncing journal-webd)
	$(call irun,echo optionfactory-*-journal-webd/deps | xargs -n 1 rsync -az install-journal-webd.sh)
	$(call irun,echo optionfactory-*-journal-webd/deps | xargs -n 1 rsync -az deps/journal-webd-${JOURNAL_WEBD_VERSION})
sync-monitoring-prometheus: deps/prometheus
	$(call task,syncing prometheus)
	$(call irun,echo optionfactory-*-prometheus/deps | xargs -n 1 rsync -az install-monitoring-prometheus.sh)
	$(call irun,echo optionfactory-*-prometheus/deps | xargs -n 1 rsync -az deps/prometheus-${PROMETHEUS_VERSION}.linux-amd64)
sync-monitoring-alertmanager: deps/alertmanager
	$(call task,syncing alertmanager)
	$(call irun,echo optionfactory-*-alertmanager/deps | xargs -n 1 rsync -az install-monitoring-alertmanager.sh)
	$(call irun,echo optionfactory-*-alertmanager/deps | xargs -n 1 rsync -az deps/alertmanager-${ALERTMANAGER_VERSION}.linux-amd64)
sync-monitoring-grafana: deps/grafana
	$(call task,syncing grafana)
	$(call irun,echo optionfactory-*-grafana/deps | xargs -n 1 rsync -az install-monitoring-grafana.sh)
	$(call irun,echo optionfactory-*-grafana/deps | xargs -n 1 rsync -az deps/grafana-${GRAFANA_VERSION})
sync-monitoring-cadvisor: deps/cadvisor
	$(call task,syncing cadvisor)
	$(call irun,echo optionfactory-*-cadvisor/deps | xargs -n 1 rsync -az install-monitoring-cadvisor.sh)
	$(call irun,echo optionfactory-*-cadvisor/deps | xargs -n 1 rsync -az deps/cadvisor-v${CADVISOR_VERSION}-linux-amd64)
sync-monitoring-postgres: deps/postgres-exporter
	$(call task,syncing monitoring-postgres)
	$(call irun,echo optionfactory-*-monitoring-postgres/deps | xargs -n 1 rsync -az install-monitoring-postgres.sh)
	$(call irun,echo optionfactory-*-monitoring-postgres/deps | xargs -n 1 rsync -az deps/postgres-exporter-${POSTGRES_EXPORTER_VERSION}-linux-amd64)
sync-monitoring-nginx: deps/nginx-exporter
	$(call task,syncing monitoring-nginx)
	$(call irun,echo optionfactory-*-monitoring-nginx/deps | xargs -n 1 rsync -az install-monitoring-nginx.sh)
	$(call irun,echo optionfactory-*-monitoring-nginx/deps | xargs -n 1 rsync -az deps/nginx-exporter-${NGINX_EXPORTER_VERSION}-linux-amd64)
sync-monitoring-host: deps/node-exporter
	$(call task,syncing monitoring-host)
	$(call irun,echo optionfactory-*-monitoring-host/deps | xargs -n 1 rsync -az install-monitoring-host.sh)
	$(call irun,echo optionfactory-*-monitoring-host/deps | xargs -n 1 rsync -az deps/node-exporter-${NODE_EXPORTER_VERSION}-linux-amd64)
sync-monitoring-tempo: deps/tempo
	$(call task,syncing monitoring-tempo)
	$(call irun,echo optionfactory-*-monitoring-tempo/deps | xargs -n 1 rsync -az install-monitoring-tempo.sh)
	$(call irun,echo optionfactory-*-monitoring-tempo/deps | xargs -n 1 rsync -az deps/tempo-${TEMPO_VERSION}-linux-amd64)


deps/gosu1: deps/gosu-${GOSU1_VERSION}
deps/legopfa1: deps/legopfa-${LEGOPFA_VERSION}
deps/maven3: deps/apache-maven-${MAVEN3_VERSION}
deps/sonarqube10: deps/sonarqube-${SONARQUBE10_VERSION}
deps/tomcat9: deps/apache-tomcat-${TOMCAT9_VERSION} deps/tomcat9-logging-error-report-valve-${TOMCAT9_ERROR_REPORT_VALVE_VERSION}.jar
deps/tomcat10: deps/apache-tomcat-${TOMCAT10_VERSION} deps/tomcat10-logging-error-report-valve-${TOMCAT10_ERROR_REPORT_VALVE_VERSION}.jar
deps/tomcat11: deps/apache-tomcat-${TOMCAT11_VERSION} deps/tomcat11-logging-error-report-valve-${TOMCAT11_ERROR_REPORT_VALVE_VERSION}.jar
deps/keycloak2: deps/keycloak-${KEYCLOAK2_VERSION} deps/optionfactory-keycloak-${KEYCLOAK_OPFA_MODULES_VERSION}
deps/nginx_remove_server_header_module: deps/opfa_http_remove_server_header_module-${NGINX_REMOVE_SERVER_HEADER_MODULE_VERSION}.so
deps/caddy2: deps/caddy-${CADDY2_VERSION}
deps/mariadb12:
deps/postgres:
deps/etcd3: deps/ectd-v${ETCD3_VERSION}-linux-amd64
deps/barman2:
deps/journal-webd: deps/journal-webd-${JOURNAL_WEBD_VERSION}
deps/prometheus: deps/prometheus-${PROMETHEUS_VERSION}.linux-amd64
deps/alertmanager: deps/alertmanager-${ALERTMANAGER_VERSION}.linux-amd64
deps/grafana: deps/grafana-v${GRAFANA_VERSION}
deps/cadvisor: deps/cadvisor-v${CADVISOR_VERSION}-linux-amd64
deps/postgres-exporter: deps/postgres-exporter-${POSTGRES_EXPORTER_VERSION}-linux-amd64
deps/nginx-exporter: deps/nginx-exporter-${NGINX_EXPORTER_VERSION}-linux-amd64
deps/node-exporter: deps/node-exporter-${NODE_EXPORTER_VERSION}-linux-amd64
deps/tempo: deps/tempo-${TEMPO_VERSION}-linux-amd64

#bsdtar -xvf-

deps/jdk21:
	$(call irun,curl -# -j -k -L https://corretto.aws/downloads/latest/amazon-corretto-21-x64-linux-jdk.tar.gz | tar xz -C deps)
deps/jdk25:
	$(call irun,curl -# -j -k -L https://corretto.aws/downloads/latest/amazon-corretto-25-x64-linux-jdk.tar.gz | tar xz -C deps)
deps/apache-maven-${MAVEN3_VERSION}:
	$(call irun,curl -# -j -k -L https://downloads.apache.org/maven/maven-3/${MAVEN3_VERSION}/binaries/apache-maven-${MAVEN3_VERSION}-bin.tar.gz | tar xz -C deps)
deps/sonarqube-${SONARQUBE10_VERSION}:
	$(call irun,cd deps && curl -# -sSL -k https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONARQUBE10_VERSION}.zip -o tmp.sonar.${SONARQUBE10_VERSION}.zip && jar xf tmp.sonar.${SONARQUBE10_VERSION}.zip; rm tmp.sonar.${SONARQUBE10_VERSION}.zip)
deps/apache-tomcat-${TOMCAT9_VERSION}:
	$(call irun,curl -# -sSL -k https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT9_VERSION}/bin/apache-tomcat-${TOMCAT9_VERSION}.tar.gz | tar xz -C deps)
deps/tomcat9-logging-error-report-valve-${TOMCAT9_ERROR_REPORT_VALVE_VERSION}.jar:
	$(call irun,curl -# -j -k -L  https://repo1.maven.org/maven2/net/optionfactory/tomcat9-logging-error-report-valve/${TOMCAT9_ERROR_REPORT_VALVE_VERSION}/tomcat9-logging-error-report-valve-${TOMCAT9_ERROR_REPORT_VALVE_VERSION}.jar -o deps/tomcat9-logging-error-report-valve-${TOMCAT9_ERROR_REPORT_VALVE_VERSION}.jar)
deps/apache-tomcat-${TOMCAT10_VERSION}:
	$(call irun,curl -# -sSL -k https://archive.apache.org/dist/tomcat/tomcat-10/v${TOMCAT10_VERSION}/bin/apache-tomcat-${TOMCAT10_VERSION}.tar.gz | tar xz -C deps)
deps/tomcat10-logging-error-report-valve-${TOMCAT10_ERROR_REPORT_VALVE_VERSION}.jar:
	$(call irun,curl -# -j -k -L  https://repo1.maven.org/maven2/net/optionfactory/tomcat9-logging-error-report-valve/${TOMCAT10_ERROR_REPORT_VALVE_VERSION}/tomcat9-logging-error-report-valve-${TOMCAT9_ERROR_REPORT_VALVE_VERSION}.jar -o deps/tomcat10-logging-error-report-valve-${TOMCAT9_ERROR_REPORT_VALVE_VERSION}.jar)
deps/apache-tomcat-${TOMCAT11_VERSION}:
	$(call irun,curl -# -sSL -k https://archive.apache.org/dist/tomcat/tomcat-11/v${TOMCAT11_VERSION}/bin/apache-tomcat-${TOMCAT11_VERSION}.tar.gz | tar xz -C deps)
deps/tomcat11-logging-error-report-valve-${TOMCAT11_ERROR_REPORT_VALVE_VERSION}.jar:
	$(call irun,curl -# -j -k -L  https://repo1.maven.org/maven2/net/optionfactory/tomcat9-logging-error-report-valve/${TOMCAT11_ERROR_REPORT_VALVE_VERSION}/tomcat9-logging-error-report-valve-${TOMCAT11_ERROR_REPORT_VALVE_VERSION}.jar -o deps/tomcat11-logging-error-report-valve-${TOMCAT11_ERROR_REPORT_VALVE_VERSION}.jar)
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
deps/cadvisor-v${CADVISOR_VERSION}-linux-amd64:
	$(call irun,curl -# -j -k -L  "https://github.com/google/cadvisor/releases/download/v${CADVISOR_VERSION}/cadvisor-v${CADVISOR_VERSION}-linux-amd64" -o deps/cadvisor-v${CADVISOR_VERSION}-linux-amd64)
deps/prometheus-${PROMETHEUS_VERSION}.linux-amd64:
	$(call irun,curl -# -j -k -L  "https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz" | tar xz -C deps)
deps/alertmanager-${ALERTMANAGER_VERSION}.linux-amd64:
	$(call irun,curl -# -j -k -L  "https://github.com/prometheus/alertmanager/releases/download/v${ALERTMANAGER_VERSION}/alertmanager-${ALERTMANAGER_VERSION}.linux-amd64.tar.gz" | tar xz -C deps)
deps/grafana-v${GRAFANA_VERSION}:
	$(call irun,curl -# -j -k -L  "https://dl.grafana.com/oss/release/grafana-${GRAFANA_VERSION}.linux-amd64.tar.gz" | tar xz -C deps)
deps/postgres-exporter-${POSTGRES_EXPORTER_VERSION}-linux-amd64:
	$(call irun,curl -# -j -k -L  "https://github.com/prometheus-community/postgres_exporter/releases/download/v${POSTGRES_EXPORTER_VERSION}/postgres_exporter-${POSTGRES_EXPORTER_VERSION}.linux-amd64.tar.gz" | tar xz --transform='s/.*/postgres-exporter-${POSTGRES_EXPORTER_VERSION}-linux-amd64/g' -C deps postgres_exporter-${POSTGRES_EXPORTER_VERSION}.linux-amd64/postgres_exporter)
deps/nginx-exporter-${NGINX_EXPORTER_VERSION}-linux-amd64:
	$(call irun,curl -# -j -k -L  "https://github.com/nginxinc/nginx-prometheus-exporter/releases/download/v${NGINX_EXPORTER_VERSION}/nginx-prometheus-exporter_${NGINX_EXPORTER_VERSION}_linux_amd64.tar.gz" | tar xz --transform='s/.*/nginx-exporter-${NGINX_EXPORTER_VERSION}-linux-amd64/g' -C deps nginx-prometheus-exporter)
deps/node-exporter-${NODE_EXPORTER_VERSION}-linux-amd64:
	$(call irun,curl -# -j -k -L  "https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz" | tar xz --transform='s/.*/node-exporter-${NODE_EXPORTER_VERSION}-linux-amd64/g' -C deps node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter)
deps/tempo-${TEMPO_VERSION}-linux-amd64:
	$(call irun,curl -# -j -k -L  "https://github.com/grafana/tempo/releases/download/v${TEMPO_VERSION}/tempo_${TEMPO_VERSION}_linux_amd64.tar.gz" | tar xz -C deps --one-top-level=tempo-${TEMPO_VERSION}-linux-amd64)

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
.PHONY: docker-images clean clean-deps

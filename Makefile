export TAG_VERSION=233-dev

#software versions

SLOTH_VERSION=1.0.0
SONARQUBE10_VERSION=26.8.0.126808
CORRETTO21_VERSION=21.0.12.9.1
CORRETTO25_VERSION=25.0.4.8.1
TOMCAT9_VERSION=9.0.121
TOMCAT9_ERROR_REPORT_VALVE_VERSION=2.1
TOMCAT10_VERSION=10.1.57
TOMCAT10_ERROR_REPORT_VALVE_VERSION=2.1
TOMCAT11_VERSION=11.0.25
TOMCAT11_ERROR_REPORT_VALVE_VERSION=2.1
LEGOPFA_VERSION=2.2
KEYCLOAK2_VERSION=26.7.2
KEYCLOAK_OPFA_MODULES_VERSION=9.11
MAVEN3_VERSION=3.9.16
CADDY2_VERSION=2.11.4
JOURNAL_WEBD_VERSION=1.1
ETCD3_VERSION=3.7.1
export NGINX_MAJOR_VERSION=1.30
NGINX_REMOVE_SERVER_HEADER_MODULE_VERSION=1.30.4-1

GRAFANA_VERSION=13.2.0
TEMPO_VERSION=3.0.3
PROMETHEUS_VERSION=3.14.0
ALERTMANAGER_VERSION=0.34.0
NODE_EXPORTER_VERSION=1.12.1
CADVISOR_VERSION=0.60.5
POSTGRES_EXPORTER_VERSION=0.20.1
NGINX_EXPORTER_VERSION=1.5.3

#/software versions

SHELL=/bin/bash -o pipefail

# canonical download flags: fail loudly on HTTP errors (no error-page bodies
# saved/piped, no retries — a wrong pin or renamed upstream asset fails fast
# and clean), follow redirects, keep session cookies, show a progress bar.
# The two $(shell) pom fetches append -s to stay silent (an -s anywhere
# suppresses the progress meter).
CURL=curl --fail --progress-bar -j -L

define task
	@echo -e "\033[1;32m"$(1)"\033[0m"
endef

define irun
   @$(1) | sed 's/^/    /'
endef

help:
	@echo usage: make [clean-deps] build
	@echo usage: make [clean-deps] build-optionfactory-debian13-jdk25-tomcat11
	@echo usage: make test
	@echo usage: make publish
	exit 1


define check_updates_tomcat
	@latest=$$(curl -s https://dlcdn.apache.org/tomcat/$1/ | grep -Po '(?<=href="v)[0-9.]+' | tail -1); \
	[ "$2" = "$$latest" ] && symbol="\033[1;32m✓\033[0m" || symbol="\033[1;31m✗\033[0m"; \
	printf "%b %-25s: current: %-20s latest: %s\n" "$$symbol" "$1" "$2" "$$latest"
endef

define check_updates_github
	@latest=$$(curl -s https://api.github.com/repos/$3/releases | jq -r '.[] | select(.prerelease == false) | .tag_name | ltrimstr("v")' | sort -V | tail -n 1); \
	[ "$2" = "$$latest" ] && symbol="\033[1;32m✓\033[0m" || symbol="\033[1;31m✗\033[0m"; \
	printf "%b %-25s: current: %-20s latest: %s\n" "$$symbol" "$1" "$2" "$$latest"
endef

define check_updates_maven
	@latest=$$(curl -s "https://repo1.maven.org/maven2/$3/maven-metadata.xml" | grep -Po '(?<=<release>)[^<]+'); \
	[ "$2" = "$$latest" ] && symbol="\033[1;32m✓\033[0m" || symbol="\033[1;31m✗\033[0m"; \
	printf "%b %-25s: current: %-20s latest: %s\n" "$$symbol" "$1" "$2" "$$latest"
endef

define check_updates_corretto
	@latest=$$(curl -sI https://corretto.aws/downloads/latest/amazon-corretto-$3-x64-linux-jdk.tar.gz | grep -i '^location:' | grep -Po '(?<=resources/)[0-9.]+'); \
	[ "$2" = "$$latest" ] && symbol="\033[1;32m✓\033[0m" || symbol="\033[1;31m✗\033[0m"; \
	printf "%b %-25s: current: %-20s latest: %s\n" "$$symbol" "corretto-$3" "$2" "$$latest"
endef

check-updates:
	$(call check_updates_corretto,corretto21,$(CORRETTO21_VERSION),21)
	$(call check_updates_corretto,corretto25,$(CORRETTO25_VERSION),25)
	$(call check_updates_github,sonarqube,$(SONARQUBE10_VERSION),SonarSource/sonarqube)
	$(call check_updates_tomcat,tomcat-9,$(TOMCAT9_VERSION))
	$(call check_updates_tomcat,tomcat-10,$(TOMCAT10_VERSION))
	$(call check_updates_tomcat,tomcat-11,$(TOMCAT11_VERSION))
	$(call check_updates_github,legopfa,$(LEGOPFA_VERSION),optionfactory/legopfa)
	$(call check_updates_github,keycloak,$(KEYCLOAK2_VERSION),keycloak/keycloak)
	$(call check_updates_maven,optionfactory-keycloak,$(KEYCLOAK_OPFA_MODULES_VERSION),net/optionfactory/keycloak/optionfactory-keycloak)
	$(call check_updates_github,caddy,$(CADDY2_VERSION),caddyserver/caddy)
	$(call check_updates_github,journal-webd,$(JOURNAL_WEBD_VERSION),optionfactory/journal-webd)
	$(call check_updates_github,etcd,$(ETCD3_VERSION),etcd-io/etcd)
	$(call check_updates_github,nginx_remove_serv,$(NGINX_REMOVE_SERVER_HEADER_MODULE_VERSION),optionfactory/nginx-remove-server-header-module)
	$(call check_updates_github,grafana,$(GRAFANA_VERSION),grafana/grafana)
	$(call check_updates_github,tempo,$(TEMPO_VERSION),grafana/tempo)
	$(call check_updates_github,prometheus,$(PROMETHEUS_VERSION),prometheus/prometheus)
	$(call check_updates_github,alertmanager,$(ALERTMANAGER_VERSION),prometheus/alertmanager)
	$(call check_updates_github,node_exporter,$(NODE_EXPORTER_VERSION),prometheus/node_exporter)
	$(call check_updates_github,cadvisor,$(CADVISOR_VERSION),google/cadvisor)
	$(call check_updates_github,postgres_exporter,$(POSTGRES_EXPORTER_VERSION),prometheus-community/postgres_exporter)
	$(call check_updates_github,nginx_exporter,$(NGINX_EXPORTER_VERSION),nginx/nginx-prometheus-exporter)
	$(call check_updates_github,sloth,$(SLOTH_VERSION),optionfactory/sloth)


verify-docker-backend:
	@docker info --format '{{json .DriverStatus}}' | grep -q "io.containerd.snapshotter.v1" || (echo -e "Docker is not configured with the containerd-snapshotter." && exit 1)

pull-base:
	$(call task,updating base images)
	$(call irun,docker pull debian:trixie-slim)

build: pull-base verify-docker-backend all-deps
	$(call task,baking all images)
	$(call irun,docker buildx bake)

build-optionfactory-%: verify-docker-backend
	$(call task,baking $(subst build-optionfactory-,,$@))
	$(call irun,docker buildx bake $(subst build-optionfactory-,,$@))

.venv/bin/python:
	$(call task,creating test virtualenv)
	$(call irun,python3 -m venv .venv)
	$(call irun,.venv/bin/pip install -q pytest)

test: verify-docker-backend .venv/bin/python
	$(call task,running smoke tests)
	$(call irun,.venv/bin/python -m pytest test -v)

publish: verify-docker-backend all-deps
	$(call task,checking TAG_VERSION is publishable)
	@case '${TAG_VERSION}' in *-dev) echo "TAG_VERSION ${TAG_VERSION} ends with -dev: refusing to push" >&2; exit 1;; esac
	$(call task,baking all images)
	$(call irun,docker buildx bake)
	$(MAKE) test
	$(call task,pushing tag: ${TAG_VERSION} and latest)
	$(call irun,docker buildx bake --push)

# per-image artifact prerequisites (parent images are resolved by bake via target: contexts)

build-optionfactory-sloth: deps-sloth
build-optionfactory-debian13-journal-webd: deps-journal-webd
build-optionfactory-debian13-etcd3: deps-etcd3
build-optionfactory-debian13-caddy2: deps-caddy2
build-optionfactory-debian13-jdk21: deps-jdk21
build-optionfactory-debian13-jdk25: deps-jdk25
build-optionfactory-debian13-jdk21-tomcat9: deps-tomcat9
build-optionfactory-debian13-jdk25-tomcat9: deps-tomcat9
build-optionfactory-debian13-jdk21-tomcat10: deps-tomcat10
build-optionfactory-debian13-jdk25-tomcat10: deps-tomcat10
build-optionfactory-debian13-jdk21-tomcat11: deps-tomcat11
build-optionfactory-debian13-jdk25-tomcat11: deps-tomcat11
build-optionfactory-debian13-jdk21-keycloak2: deps-keycloak2
build-optionfactory-debian13-jdk25-keycloak2: deps-keycloak2
build-optionfactory-debian13-jdk25-sonarqube10: deps-sonarqube10
build-optionfactory-debian13-jdk21-builder: deps-maven3
build-optionfactory-debian13-jdk25-builder: deps-maven3
build-optionfactory-debian13-nginx130: deps-nginx130
build-optionfactory-debian13-monitoring-prometheus: deps-prometheus
build-optionfactory-debian13-monitoring-alertmanager: deps-alertmanager
build-optionfactory-debian13-monitoring-grafana: deps-grafana
build-optionfactory-debian13-monitoring-cadvisor: deps-cadvisor
build-optionfactory-debian13-monitoring-postgres: deps-postgres-exporter
build-optionfactory-debian13-monitoring-nginx: deps-nginx-exporter
build-optionfactory-debian13-monitoring-host: deps-node-exporter
build-optionfactory-debian13-monitoring-tempo: deps-tempo


# artifact families: deps/<family> holds exactly the artifacts an image needs,
# wiped and re-downloaded whenever any pinned version in its stamp changes

all-deps: deps-jdk21 deps-jdk25 deps-maven3 deps-sonarqube10 deps-tomcat9 deps-tomcat10 deps-tomcat11 deps-keycloak2 deps-nginx130 deps-caddy2 deps-etcd3 deps-journal-webd deps-prometheus deps-alertmanager deps-grafana deps-cadvisor deps-postgres-exporter deps-nginx-exporter deps-node-exporter deps-tempo deps-sloth

deps-jdk21: deps/jdk21/.stamp-$(CORRETTO21_VERSION)
deps-jdk25: deps/jdk25/.stamp-$(CORRETTO25_VERSION)
deps-maven3: deps/maven3/.stamp-$(MAVEN3_VERSION)
deps-sonarqube10: deps/sonarqube10/.stamp-$(SONARQUBE10_VERSION)
deps-tomcat9: deps/tomcat9/.stamp-$(TOMCAT9_VERSION)-$(TOMCAT9_ERROR_REPORT_VALVE_VERSION)
deps-tomcat10: deps/tomcat10/.stamp-$(TOMCAT10_VERSION)-$(TOMCAT10_ERROR_REPORT_VALVE_VERSION)
deps-tomcat11: deps/tomcat11/.stamp-$(TOMCAT11_VERSION)-$(TOMCAT11_ERROR_REPORT_VALVE_VERSION)
deps-keycloak2: deps/keycloak2/.stamp-$(KEYCLOAK2_VERSION)-$(KEYCLOAK_OPFA_MODULES_VERSION)
deps-nginx130: deps/nginx130/.stamp-$(NGINX_REMOVE_SERVER_HEADER_MODULE_VERSION)-$(LEGOPFA_VERSION)
deps-caddy2: deps/caddy2/.stamp-$(CADDY2_VERSION)
deps-etcd3: deps/etcd3/.stamp-$(ETCD3_VERSION)
deps-journal-webd: deps/journal-webd/.stamp-$(JOURNAL_WEBD_VERSION)
deps-prometheus: deps/prometheus/.stamp-$(PROMETHEUS_VERSION)
deps-alertmanager: deps/alertmanager/.stamp-$(ALERTMANAGER_VERSION)
deps-grafana: deps/grafana/.stamp-$(GRAFANA_VERSION)
deps-cadvisor: deps/cadvisor/.stamp-$(CADVISOR_VERSION)
deps-postgres-exporter: deps/postgres-exporter/.stamp-$(POSTGRES_EXPORTER_VERSION)
deps-nginx-exporter: deps/nginx-exporter/.stamp-$(NGINX_EXPORTER_VERSION)
deps-node-exporter: deps/node-exporter/.stamp-$(NODE_EXPORTER_VERSION)
deps-tempo: deps/tempo/.stamp-$(TEMPO_VERSION)
deps-sloth: deps/sloth/.stamp-$(SLOTH_VERSION)


deps/jdk21/.stamp-$(CORRETTO21_VERSION):
	$(call task,downloading corretto $(CORRETTO21_VERSION))
	$(call irun,rm -rf deps/jdk21 && mkdir -p deps/jdk21)
	$(call irun,$(CURL) https://corretto.aws/downloads/resources/$(CORRETTO21_VERSION)/amazon-corretto-$(CORRETTO21_VERSION)-linux-x64.tar.gz | tar xz -C deps/jdk21)
	$(call irun,touch $@)
deps/jdk25/.stamp-$(CORRETTO25_VERSION):
	$(call task,downloading corretto $(CORRETTO25_VERSION))
	$(call irun,rm -rf deps/jdk25 && mkdir -p deps/jdk25)
	$(call irun,$(CURL) https://corretto.aws/downloads/resources/$(CORRETTO25_VERSION)/amazon-corretto-$(CORRETTO25_VERSION)-linux-x64.tar.gz | tar xz -C deps/jdk25)
	$(call irun,touch $@)
deps/maven3/.stamp-$(MAVEN3_VERSION):
	$(call task,downloading maven $(MAVEN3_VERSION))
	$(call irun,rm -rf deps/maven3 && mkdir -p deps/maven3)
	$(call irun,$(CURL) https://downloads.apache.org/maven/maven-3/$(MAVEN3_VERSION)/binaries/apache-maven-$(MAVEN3_VERSION)-bin.tar.gz | tar xz -C deps/maven3)
	$(call irun,touch $@)
deps/sonarqube10/.stamp-$(SONARQUBE10_VERSION):
	$(call task,downloading sonarqube $(SONARQUBE10_VERSION))
	$(call irun,rm -rf deps/sonarqube10 && mkdir -p deps/sonarqube10)
	$(call irun,cd deps/sonarqube10 && $(CURL) https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-$(SONARQUBE10_VERSION).zip -o tmp.sonar.zip && unzip -q tmp.sonar.zip && rm tmp.sonar.zip)
	$(call irun,touch $@)
deps/tomcat9/.stamp-$(TOMCAT9_VERSION)-$(TOMCAT9_ERROR_REPORT_VALVE_VERSION):
	$(call task,downloading tomcat $(TOMCAT9_VERSION))
	$(call irun,rm -rf deps/tomcat9 && mkdir -p deps/tomcat9)
	$(call irun,$(CURL) https://archive.apache.org/dist/tomcat/tomcat-9/v$(TOMCAT9_VERSION)/bin/apache-tomcat-$(TOMCAT9_VERSION).tar.gz | tar xz -C deps/tomcat9)
	$(call irun,$(CURL) https://repo1.maven.org/maven2/net/optionfactory/tomcat9-logging-error-report-valve/$(TOMCAT9_ERROR_REPORT_VALVE_VERSION)/tomcat9-logging-error-report-valve-$(TOMCAT9_ERROR_REPORT_VALVE_VERSION).jar -o deps/tomcat9/tomcat9-logging-error-report-valve-$(TOMCAT9_ERROR_REPORT_VALVE_VERSION).jar)
	$(call irun,touch $@)
deps/tomcat10/.stamp-$(TOMCAT10_VERSION)-$(TOMCAT10_ERROR_REPORT_VALVE_VERSION):
	$(call task,downloading tomcat $(TOMCAT10_VERSION))
	$(call irun,rm -rf deps/tomcat10 && mkdir -p deps/tomcat10)
	$(call irun,$(CURL) https://archive.apache.org/dist/tomcat/tomcat-10/v$(TOMCAT10_VERSION)/bin/apache-tomcat-$(TOMCAT10_VERSION).tar.gz | tar xz -C deps/tomcat10)
	$(call irun,$(CURL) https://repo1.maven.org/maven2/net/optionfactory/tomcat9-logging-error-report-valve/$(TOMCAT10_ERROR_REPORT_VALVE_VERSION)/tomcat9-logging-error-report-valve-$(TOMCAT10_ERROR_REPORT_VALVE_VERSION).jar -o deps/tomcat10/tomcat10-logging-error-report-valve-$(TOMCAT10_ERROR_REPORT_VALVE_VERSION).jar)
	$(call irun,touch $@)
deps/tomcat11/.stamp-$(TOMCAT11_VERSION)-$(TOMCAT11_ERROR_REPORT_VALVE_VERSION):
	$(call task,downloading tomcat $(TOMCAT11_VERSION))
	$(call irun,rm -rf deps/tomcat11 && mkdir -p deps/tomcat11)
	$(call irun,$(CURL) https://archive.apache.org/dist/tomcat/tomcat-11/v$(TOMCAT11_VERSION)/bin/apache-tomcat-$(TOMCAT11_VERSION).tar.gz | tar xz -C deps/tomcat11)
	$(call irun,$(CURL) https://repo1.maven.org/maven2/net/optionfactory/tomcat9-logging-error-report-valve/$(TOMCAT11_ERROR_REPORT_VALVE_VERSION)/tomcat9-logging-error-report-valve-$(TOMCAT11_ERROR_REPORT_VALVE_VERSION).jar -o deps/tomcat11/tomcat11-logging-error-report-valve-$(TOMCAT11_ERROR_REPORT_VALVE_VERSION).jar)
	$(call irun,touch $@)
deps/keycloak2/.stamp-$(KEYCLOAK2_VERSION)-$(KEYCLOAK_OPFA_MODULES_VERSION):
	$(call task,downloading keycloak $(KEYCLOAK2_VERSION) + optionfactory-keycloak $(KEYCLOAK_OPFA_MODULES_VERSION))
	$(call irun,rm -rf deps/keycloak2 && mkdir -p deps/keycloak2)
	$(call irun,$(CURL) https://github.com/keycloak/keycloak/releases/download/$(KEYCLOAK2_VERSION)/keycloak-$(KEYCLOAK2_VERSION).tar.gz | tar xz -C deps/keycloak2)
	$(call irun,mkdir -p deps/keycloak2/optionfactory-keycloak-$(KEYCLOAK_OPFA_MODULES_VERSION))
	$(eval modules=$(shell $(CURL) -s https://repo1.maven.org/maven2/net/optionfactory/keycloak/optionfactory-keycloak/$(KEYCLOAK_OPFA_MODULES_VERSION)/optionfactory-keycloak-$(KEYCLOAK_OPFA_MODULES_VERSION).pom | grep '<module>' | grep -Po '(?<=>)[^<]+(?=<)'))
	$(call irun,test -n "${modules}" || (echo "could not resolve optionfactory-keycloak modules from maven" && false))
	$(call irun,for module in ${modules}; do $(CURL) "https://repo1.maven.org/maven2/net/optionfactory/keycloak/$${module}/$(KEYCLOAK_OPFA_MODULES_VERSION)/$${module}-$(KEYCLOAK_OPFA_MODULES_VERSION).jar" > "deps/keycloak2/optionfactory-keycloak-$(KEYCLOAK_OPFA_MODULES_VERSION)/$${module}.jar"; done)
	$(eval lpn_version=$(shell $(CURL) -s https://repo1.maven.org/maven2/net/optionfactory/keycloak/optionfactory-keycloak/$(KEYCLOAK_OPFA_MODULES_VERSION)/optionfactory-keycloak-$(KEYCLOAK_OPFA_MODULES_VERSION).pom | grep '<libphonenumber.version>' | grep -Po '(?<=>)[^<]+(?=<)'))
	$(call irun,test -n "${lpn_version}" || (echo "could not resolve libphonenumber version from the optionfactory-keycloak pom" && false))
	$(call irun,$(CURL) "https://repo1.maven.org/maven2/com/googlecode/libphonenumber/libphonenumber/${lpn_version}/libphonenumber-${lpn_version}.jar" > "deps/keycloak2/optionfactory-keycloak-$(KEYCLOAK_OPFA_MODULES_VERSION)/libphonenumber-${lpn_version}.jar")
	$(call irun,touch $@)
deps/nginx130/.stamp-$(NGINX_REMOVE_SERVER_HEADER_MODULE_VERSION)-$(LEGOPFA_VERSION):
	$(call task,downloading nginx-remove-server-header-module $(NGINX_REMOVE_SERVER_HEADER_MODULE_VERSION) + legopfa $(LEGOPFA_VERSION))
	$(call irun,rm -rf deps/nginx130 && mkdir -p deps/nginx130)
	$(call irun,$(CURL) https://github.com/optionfactory/nginx-remove-server-header-module/releases/download/v$(NGINX_REMOVE_SERVER_HEADER_MODULE_VERSION)/opfa_http_remove_server_header_module-$(NGINX_REMOVE_SERVER_HEADER_MODULE_VERSION).so -o deps/nginx130/opfa_http_remove_server_header_module-$(NGINX_REMOVE_SERVER_HEADER_MODULE_VERSION).so)
	$(call irun,$(CURL) https://github.com/optionfactory/legopfa/releases/download/v$(LEGOPFA_VERSION)/legopfa-linux-amd64 -o deps/nginx130/legopfa-$(LEGOPFA_VERSION))
	$(call irun,chmod +x deps/nginx130/legopfa-$(LEGOPFA_VERSION))
	$(call irun,touch $@)
deps/caddy2/.stamp-$(CADDY2_VERSION):
	$(call task,downloading caddy $(CADDY2_VERSION))
	$(call irun,rm -rf deps/caddy2 && mkdir -p deps/caddy2)
	$(call irun,$(CURL) "https://github.com/caddyserver/caddy/releases/download/v$(CADDY2_VERSION)/caddy_$(CADDY2_VERSION)_linux_amd64.tar.gz" | tar xz -C deps/caddy2 caddy && mv deps/caddy2/caddy deps/caddy2/caddy-$(CADDY2_VERSION))
	$(call irun,touch $@)
deps/etcd3/.stamp-$(ETCD3_VERSION):
	$(call task,downloading etcd $(ETCD3_VERSION))
	$(call irun,rm -rf deps/etcd3 && mkdir -p deps/etcd3)
	$(call irun,$(CURL) "https://github.com/etcd-io/etcd/releases/download/v$(ETCD3_VERSION)/etcd-v$(ETCD3_VERSION)-linux-amd64.tar.gz" | tar xz -C deps/etcd3)
	$(call irun,touch $@)
deps/journal-webd/.stamp-$(JOURNAL_WEBD_VERSION):
	$(call task,downloading journal-webd $(JOURNAL_WEBD_VERSION))
	$(call irun,rm -rf deps/journal-webd && mkdir -p deps/journal-webd)
	$(call irun,$(CURL) "https://github.com/optionfactory/journal-webd/releases/download/$(JOURNAL_WEBD_VERSION)/journal-webd-$(JOURNAL_WEBD_VERSION)" -o deps/journal-webd/journal-webd-$(JOURNAL_WEBD_VERSION))
	$(call irun,chmod +x deps/journal-webd/journal-webd-$(JOURNAL_WEBD_VERSION))
	$(call irun,touch $@)
deps/prometheus/.stamp-$(PROMETHEUS_VERSION):
	$(call task,downloading prometheus $(PROMETHEUS_VERSION))
	$(call irun,rm -rf deps/prometheus && mkdir -p deps/prometheus)
	$(call irun,$(CURL) "https://github.com/prometheus/prometheus/releases/download/v$(PROMETHEUS_VERSION)/prometheus-$(PROMETHEUS_VERSION).linux-amd64.tar.gz" | tar xz -C deps/prometheus)
	$(call irun,touch $@)
deps/alertmanager/.stamp-$(ALERTMANAGER_VERSION):
	$(call task,downloading alertmanager $(ALERTMANAGER_VERSION))
	$(call irun,rm -rf deps/alertmanager && mkdir -p deps/alertmanager)
	$(call irun,$(CURL) "https://github.com/prometheus/alertmanager/releases/download/v$(ALERTMANAGER_VERSION)/alertmanager-$(ALERTMANAGER_VERSION).linux-amd64.tar.gz" | tar xz -C deps/alertmanager)
	$(call irun,touch $@)
deps/grafana/.stamp-$(GRAFANA_VERSION):
	$(call task,downloading grafana $(GRAFANA_VERSION))
	$(call irun,rm -rf deps/grafana && mkdir -p deps/grafana)
	$(call irun,$(CURL) "https://dl.grafana.com/oss/release/grafana-$(GRAFANA_VERSION).linux-amd64.tar.gz" | tar xz -C deps/grafana)
	$(call irun,touch $@)
deps/cadvisor/.stamp-$(CADVISOR_VERSION):
	$(call task,downloading cadvisor $(CADVISOR_VERSION))
	$(call irun,rm -rf deps/cadvisor && mkdir -p deps/cadvisor)
	$(call irun,$(CURL) "https://github.com/google/cadvisor/releases/download/v$(CADVISOR_VERSION)/cadvisor-v$(CADVISOR_VERSION)-linux-amd64" -o deps/cadvisor/cadvisor-v$(CADVISOR_VERSION)-linux-amd64)
	$(call irun,chmod +x deps/cadvisor/cadvisor-v$(CADVISOR_VERSION)-linux-amd64)
	$(call irun,touch $@)
deps/postgres-exporter/.stamp-$(POSTGRES_EXPORTER_VERSION):
	$(call task,downloading postgres-exporter $(POSTGRES_EXPORTER_VERSION))
	$(call irun,rm -rf deps/postgres-exporter && mkdir -p deps/postgres-exporter)
	$(call irun,$(CURL) "https://github.com/prometheus-community/postgres_exporter/releases/download/v$(POSTGRES_EXPORTER_VERSION)/postgres_exporter-$(POSTGRES_EXPORTER_VERSION).linux-amd64.tar.gz" | tar xz -C deps/postgres-exporter --strip-components=1 postgres_exporter-$(POSTGRES_EXPORTER_VERSION).linux-amd64/postgres_exporter && mv deps/postgres-exporter/postgres_exporter deps/postgres-exporter/postgres-exporter-$(POSTGRES_EXPORTER_VERSION)-linux-amd64)
	$(call irun,chmod +x deps/postgres-exporter/postgres-exporter-$(POSTGRES_EXPORTER_VERSION)-linux-amd64)
	$(call irun,touch $@)
deps/nginx-exporter/.stamp-$(NGINX_EXPORTER_VERSION):
	$(call task,downloading nginx-exporter $(NGINX_EXPORTER_VERSION))
	$(call irun,rm -rf deps/nginx-exporter && mkdir -p deps/nginx-exporter)
	$(call irun,$(CURL) "https://github.com/nginxinc/nginx-prometheus-exporter/releases/download/v$(NGINX_EXPORTER_VERSION)/nginx-prometheus-exporter_$(NGINX_EXPORTER_VERSION)_linux_amd64.tar.gz" | tar xz -C deps/nginx-exporter nginx-prometheus-exporter && mv deps/nginx-exporter/nginx-prometheus-exporter deps/nginx-exporter/nginx-exporter-$(NGINX_EXPORTER_VERSION)-linux-amd64)
	$(call irun,chmod +x deps/nginx-exporter/nginx-exporter-$(NGINX_EXPORTER_VERSION)-linux-amd64)
	$(call irun,touch $@)
deps/node-exporter/.stamp-$(NODE_EXPORTER_VERSION):
	$(call task,downloading node-exporter $(NODE_EXPORTER_VERSION))
	$(call irun,rm -rf deps/node-exporter && mkdir -p deps/node-exporter)
	$(call irun,$(CURL) "https://github.com/prometheus/node_exporter/releases/download/v$(NODE_EXPORTER_VERSION)/node_exporter-$(NODE_EXPORTER_VERSION).linux-amd64.tar.gz" | tar xz -C deps/node-exporter --strip-components=1 node_exporter-$(NODE_EXPORTER_VERSION).linux-amd64/node_exporter && mv deps/node-exporter/node_exporter deps/node-exporter/node-exporter-$(NODE_EXPORTER_VERSION)-linux-amd64)
	$(call irun,chmod +x deps/node-exporter/node-exporter-$(NODE_EXPORTER_VERSION)-linux-amd64)
	$(call irun,touch $@)
deps/tempo/.stamp-$(TEMPO_VERSION):
	$(call task,downloading tempo $(TEMPO_VERSION))
	$(call irun,rm -rf deps/tempo && mkdir -p deps/tempo)
	$(call irun,$(CURL) "https://github.com/grafana/tempo/releases/download/v$(TEMPO_VERSION)/tempo_$(TEMPO_VERSION)_linux_amd64.tar.gz" | tar xz -C deps/tempo --one-top-level=tempo-$(TEMPO_VERSION)-linux-amd64)
	$(call irun,chmod +x deps/tempo/tempo-$(TEMPO_VERSION)-linux-amd64/tempo)
	$(call irun,touch $@)
deps/sloth/.stamp-$(SLOTH_VERSION):
	$(call task,downloading sloth $(SLOTH_VERSION))
	$(call irun,rm -rf deps/sloth && mkdir -p deps/sloth)
	$(call irun,$(CURL) https://github.com/optionfactory/sloth/releases/download/v$(SLOTH_VERSION)/sloth-v$(SLOTH_VERSION)-x86_64-unknown-linux-musl -o deps/sloth/sloth)
	$(call irun,chmod +x deps/sloth/sloth)
	$(call irun,touch $@)


clean-deps: FORCE
	$(call task,removing cached deps)
	$(call irun,rm -rf deps/*)

cleanup-docker-images: FORCE
	$(call task,stats before)
	$(call irun,docker system df)
	$(call task,removing old tags)
	$(call irun, docker images --format "{{.Repository}}:{{.Tag}}" --filter "reference=optionfactory/*" | awk -F: '$$2 < ${TAG_VERSION} {print $$0}' | xargs -I{} docker rmi {})
	$(call task,removing dangling images)
	$(call irun, docker images --quiet --filter=dangling=true | xargs --no-run-if-empty docker rmi)
	$(call task,removing volumes)
	$(call irun, docker volume prune -f)
	$(call task,removing builder cache)
	$(call irun, docker builder prune -f)
	$(call task,status after)
	$(call irun, docker system df)

#If a rule has no prerequisites or recipe, and the target of the rule is a nonexistent file,
#then make imagines this target to have been updated whenever its rule is run.
#This implies that all targets depending on this one will always have their recipe run.
FORCE:
.PHONY: build publish test check-updates verify-docker-backend pull-base all-deps clean-deps cleanup-docker-images
.PHONY: deps-jdk21 deps-jdk25 deps-maven3 deps-sonarqube10 deps-tomcat9 deps-tomcat10 deps-tomcat11 deps-keycloak2 deps-nginx130 deps-caddy2 deps-etcd3 deps-journal-webd deps-prometheus deps-alertmanager deps-grafana deps-cadvisor deps-postgres-exporter deps-nginx-exporter deps-node-exporter deps-tempo deps-sloth

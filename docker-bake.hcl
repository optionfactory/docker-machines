# build graph for all optionfactory images.
# pins live in the Makefile and flow in via environment variables.
# dockerfiles are rendered inline per target: there are no per-image Dockerfiles
# or context directories, every input arrives via named build contexts
# (scripts, distrib, base); the main context defaults to the repo root, emptied
# by the root .dockerignore.

variable "TAG_VERSION" {}
variable "NGINX_MAJOR_VERSION" { default = "1.30" }

function "base" {
  params = [from]
  result = join("\n", [
    "FROM ${from}",
    "LABEL maintainer=\"Roberto Ferranti <roberto@optionfactory.net>\"",
    "LABEL org.opencontainers.image.source=https://github.com/optionfactory/docker-machines",
  ])
}

function "run_debian13" {
  params = [script, distrib, envs]
  result = join(" \\\n    ", compact(concat(
    ["RUN --mount=type=bind,from=scripts,target=/build-scripts"],
    distrib ? ["--mount=type=bind,from=distrib,target=/build"] : [],
    ["DISTRIB_LABEL=debian13 DISTRIB_ID=debian DISTRIB_RELEASE=13 DISTRIB_CODENAME=trixie"],
    envs,
    ["/build-scripts/${script}"],
  )))
}

function "tags" {
  params = [name]
  result = [
    "docker.io/optionfactory/${name}:${TAG_VERSION}",
    "docker.io/optionfactory/${name}:latest",
    # emergency dockerhub-rugpull escape hatch: uncomment, docker login ghcr.io, make publish-github
    # "ghcr.io/optionfactory/${name}:${TAG_VERSION}",
    # "ghcr.io/optionfactory/${name}:latest",
  ]
}

group "default" {
  targets = [
    "debian13",
    "sloth",
    "debian13-medic",
    "debian13-barman2",
    "debian13-journal-webd",
    "debian13-etcd3",
    "debian13-caddy2",
    "debian13-mariadb12",
    "debian13-mysql8",
    "debian13-mysql9",
    "debian13-postgres15",
    "debian13-postgres16",
    "debian13-postgres17",
    "debian13-postgres18",
    "debian13-jdk21",
    "debian13-jdk25",
    "debian13-jdk21-tomcat9",
    "debian13-jdk25-tomcat9",
    "debian13-jdk21-tomcat10",
    "debian13-jdk25-tomcat10",
    "debian13-jdk21-tomcat11",
    "debian13-jdk25-tomcat11",
    "debian13-jdk21-keycloak2",
    "debian13-jdk25-keycloak2",
    "debian13-jdk25-sonarqube10",
    "debian13-jdk21-builder",
    "debian13-jdk25-builder",
    "debian13-nginx130",
    "debian13-monitoring-prometheus",
    "debian13-monitoring-alertmanager",
    "debian13-monitoring-grafana",
    "debian13-monitoring-cadvisor",
    "debian13-monitoring-postgres",
    "debian13-monitoring-nginx",
    "debian13-monitoring-host",
    "debian13-monitoring-tempo",
  ]
}

# base image

target "debian13" {
  attest = ["type=sbom", "type=provenance,mode=max"]
  tags = tags("debian13")
  contexts = { scripts = "scripts" }
  dockerfile-inline = <<-EOF
    ${base("debian:trixie-slim")}

    ${run_debian13("install-base-image.sh", false, [])}
  EOF
}

# static binary in a FROM scratch image

target "sloth" {
  attest = ["type=sbom", "type=provenance,mode=max"]
  tags = tags("sloth")
  contexts = { bin = "deps/sloth" }
  dockerfile-inline = <<-EOF
    ${base("scratch")}

    COPY --from=bin /sloth /sloth

    ENTRYPOINT ["/sloth"]
  EOF
}

# script-only images

target "debian13-medic" {
  attest = ["type=sbom", "type=provenance,mode=max"]
  tags = tags("debian13-medic")
  contexts = { scripts = "scripts", base = "target:debian13" }
  dockerfile-inline = <<-EOF
    ${base("base")}

    ${run_debian13("install-medic.sh", false, [])}
  EOF
}

target "debian13-barman2" {
  attest = ["type=sbom", "type=provenance,mode=max"]
  tags = tags("debian13-barman2")
  contexts = { scripts = "scripts", base = "target:debian13" }
  dockerfile-inline = <<-EOF
    ${base("base")}

    ${run_debian13("install-barman.sh", false, [])}

    ENTRYPOINT ["/barman"]
  EOF
}

target "debian13-mariadb12" {
  attest = ["type=sbom", "type=provenance,mode=max"]
  tags = tags("debian13-mariadb12")
  contexts = { scripts = "scripts", base = "target:debian13" }
  dockerfile-inline = <<-EOF
    ${base("base")}

    ${run_debian13("install-mariadb.sh", false, ["MARIA_DB_VERSION=12.rolling"])}

    VOLUME ["/var/lib/mysql", "/sql-init.d/"]
    ENTRYPOINT ["/mariadb"]
  EOF
}

target "debian13-mysql8" {
  attest = ["type=sbom", "type=provenance,mode=max"]
  tags = tags("debian13-mysql8")
  contexts = { scripts = "scripts", base = "target:debian13" }
  dockerfile-inline = <<-EOF
    ${base("base")}

    ${run_debian13("install-mysql.sh", false, ["MYSQL_VERSION=8.4-lts"])}

    VOLUME ["/var/lib/mysql", "/sql-init.d/"]
    ENTRYPOINT ["/mysql"]
  EOF
}

target "debian13-mysql9" {
  attest = ["type=sbom", "type=provenance,mode=max"]
  tags = tags("debian13-mysql9")
  contexts = { scripts = "scripts", base = "target:debian13" }
  dockerfile-inline = <<-EOF
    ${base("base")}

    ${run_debian13("install-mysql.sh", false, ["MYSQL_VERSION=9.7-lts"])}

    VOLUME ["/var/lib/mysql", "/sql-init.d/"]
    ENTRYPOINT ["/mysql"]
  EOF
}

target "debian13-postgres15" {
  attest = ["type=sbom", "type=provenance,mode=max"]
  tags = tags("debian13-postgres15")
  contexts = { scripts = "scripts", base = "target:debian13" }
  dockerfile-inline = <<-EOF
    ${base("base")}

    ${run_debian13("install-postgres.sh", false, ["PSQL_MAJOR_VERSION=15"])}

    VOLUME ["/var/lib/postgresql/data/", "/sql-init.d/"]
    ENTRYPOINT ["/postgres"]
  EOF
}

target "debian13-postgres16" {
  attest = ["type=sbom", "type=provenance,mode=max"]
  tags = tags("debian13-postgres16")
  contexts = { scripts = "scripts", base = "target:debian13" }
  dockerfile-inline = <<-EOF
    ${base("base")}

    ${run_debian13("install-postgres.sh", false, ["PSQL_MAJOR_VERSION=16"])}

    VOLUME ["/var/lib/postgresql/data/", "/sql-init.d/"]
    ENTRYPOINT ["/postgres"]
  EOF
}

target "debian13-postgres17" {
  attest = ["type=sbom", "type=provenance,mode=max"]
  tags = tags("debian13-postgres17")
  contexts = { scripts = "scripts", base = "target:debian13" }
  dockerfile-inline = <<-EOF
    ${base("base")}

    ${run_debian13("install-postgres.sh", false, ["PSQL_MAJOR_VERSION=17"])}

    VOLUME ["/var/lib/postgresql/data/", "/sql-init.d/"]
    ENTRYPOINT ["/postgres"]
  EOF
}

target "debian13-postgres18" {
  attest = ["type=sbom", "type=provenance,mode=max"]
  tags = tags("debian13-postgres18")
  contexts = { scripts = "scripts", base = "target:debian13" }
  dockerfile-inline = <<-EOF
    ${base("base")}

    ${run_debian13("install-postgres.sh", false, ["PSQL_MAJOR_VERSION=18"])}

    VOLUME ["/var/lib/postgresql/data/", "/sql-init.d/"]
    ENTRYPOINT ["/postgres"]
  EOF
}

# single-artifact images

target "debian13-journal-webd" {
  attest = ["type=sbom", "type=provenance,mode=max"]
  tags = tags("debian13-journal-webd")
  contexts = { scripts = "scripts", base = "target:debian13", distrib = "deps/journal-webd" }
  dockerfile-inline = <<-EOF
    ${base("base")}

    ${run_debian13("install-journal-webd.sh", true, [])}

    ENTRYPOINT ["/journal-webd", "/journal-webd-conf/configuration.json"]
  EOF
}

target "debian13-etcd3" {
  attest = ["type=sbom", "type=provenance,mode=max"]
  tags = tags("debian13-etcd3")
  contexts = { scripts = "scripts", base = "target:debian13", distrib = "deps/etcd3" }
  dockerfile-inline = <<-EOF
    ${base("base")}

    ${run_debian13("install-etcd.sh", true, [])}

    ENTRYPOINT ["/etcd"]
  EOF
}

target "debian13-caddy2" {
  attest = ["type=sbom", "type=provenance,mode=max"]
  tags = tags("debian13-caddy2")
  contexts = { scripts = "scripts", base = "target:debian13", distrib = "deps/caddy2" }
  dockerfile-inline = <<-EOF
    ${base("base")}

    ${run_debian13("install-caddy.sh", true, [])}

    ENTRYPOINT ["/caddy"]
  EOF
}

target "debian13-nginx130" {
  attest = ["type=sbom", "type=provenance,mode=max"]
  tags = tags("debian13-nginx130")
  contexts = { scripts = "scripts", base = "target:debian13", distrib = "deps/nginx130" }
  dockerfile-inline = <<-EOF
    ${base("base")}

    ${run_debian13("install-nginx.sh", true, ["NGINX_MAJOR_VERSION=${NGINX_MAJOR_VERSION}"])}

    ENTRYPOINT ["/nginx"]
  EOF
}

target "debian13-jdk21" {
  attest = ["type=sbom", "type=provenance,mode=max"]
  tags = tags("debian13-jdk21")
  contexts = { scripts = "scripts", base = "target:debian13", distrib = "deps/jdk21" }
  dockerfile-inline = <<-EOF
    ${base("base")}

    ${run_debian13("install-jdk.sh", true, [])}
  EOF
}

target "debian13-jdk25" {
  attest = ["type=sbom", "type=provenance,mode=max"]
  tags = tags("debian13-jdk25")
  contexts = { scripts = "scripts", base = "target:debian13", distrib = "deps/jdk25" }
  dockerfile-inline = <<-EOF
    ${base("base")}

    ${run_debian13("install-jdk.sh", true, [])}
  EOF
}

target "debian13-jdk25-sonarqube10" {
  attest = ["type=sbom", "type=provenance,mode=max"]
  tags = tags("debian13-jdk25-sonarqube10")
  contexts = { scripts = "scripts", base = "target:debian13-jdk25", distrib = "deps/sonarqube10" }
  dockerfile-inline = <<-EOF
    ${base("base")}

    ${run_debian13("install-sonarqube.sh", true, [])}

    ENTRYPOINT ["/sonarqube"]
  EOF
}

target "debian13-jdk21-builder" {
  attest = ["type=sbom", "type=provenance,mode=max"]
  tags = tags("debian13-jdk21-builder")
  contexts = { scripts = "scripts", base = "target:debian13-jdk21", distrib = "deps/maven3" }
  dockerfile-inline = <<-EOF
    ${base("base")}

    ${run_debian13("install-builder.sh", true, [])}

    WORKDIR /home/builder
    USER builder
  EOF
}

target "debian13-jdk25-builder" {
  attest = ["type=sbom", "type=provenance,mode=max"]
  tags = tags("debian13-jdk25-builder")
  contexts = { scripts = "scripts", base = "target:debian13-jdk25", distrib = "deps/maven3" }
  dockerfile-inline = <<-EOF
    ${base("base")}

    ${run_debian13("install-builder.sh", true, [])}

    WORKDIR /home/builder
    USER builder
  EOF
}

target "debian13-jdk21-tomcat9" {
  attest = ["type=sbom", "type=provenance,mode=max"]
  tags = tags("debian13-jdk21-tomcat9")
  contexts = { scripts = "scripts", base = "target:debian13-jdk21", distrib = "deps/tomcat9" }
  dockerfile-inline = <<-EOF
    ${base("base")}

    ${run_debian13("install-tomcat.sh", true, ["TOMCAT_MAJOR_VERSION=9"])}

    ENTRYPOINT ["/tomcat"]
  EOF
}

target "debian13-jdk25-tomcat9" {
  attest = ["type=sbom", "type=provenance,mode=max"]
  tags = tags("debian13-jdk25-tomcat9")
  contexts = { scripts = "scripts", base = "target:debian13-jdk25", distrib = "deps/tomcat9" }
  dockerfile-inline = <<-EOF
    ${base("base")}

    ${run_debian13("install-tomcat.sh", true, ["TOMCAT_MAJOR_VERSION=9"])}

    ENTRYPOINT ["/tomcat"]
  EOF
}

target "debian13-jdk21-tomcat10" {
  attest = ["type=sbom", "type=provenance,mode=max"]
  tags = tags("debian13-jdk21-tomcat10")
  contexts = { scripts = "scripts", base = "target:debian13-jdk21", distrib = "deps/tomcat10" }
  dockerfile-inline = <<-EOF
    ${base("base")}

    ${run_debian13("install-tomcat.sh", true, ["TOMCAT_MAJOR_VERSION=10"])}

    ENTRYPOINT ["/tomcat"]
  EOF
}

target "debian13-jdk25-tomcat10" {
  attest = ["type=sbom", "type=provenance,mode=max"]
  tags = tags("debian13-jdk25-tomcat10")
  contexts = { scripts = "scripts", base = "target:debian13-jdk25", distrib = "deps/tomcat10" }
  dockerfile-inline = <<-EOF
    ${base("base")}

    ${run_debian13("install-tomcat.sh", true, ["TOMCAT_MAJOR_VERSION=10"])}

    ENTRYPOINT ["/tomcat"]
  EOF
}

target "debian13-jdk21-tomcat11" {
  attest = ["type=sbom", "type=provenance,mode=max"]
  tags = tags("debian13-jdk21-tomcat11")
  contexts = { scripts = "scripts", base = "target:debian13-jdk21", distrib = "deps/tomcat11" }
  dockerfile-inline = <<-EOF
    ${base("base")}

    ${run_debian13("install-tomcat.sh", true, ["TOMCAT_MAJOR_VERSION=11"])}

    ENTRYPOINT ["/tomcat"]
  EOF
}

target "debian13-jdk25-tomcat11" {
  attest = ["type=sbom", "type=provenance,mode=max"]
  tags = tags("debian13-jdk25-tomcat11")
  contexts = { scripts = "scripts", base = "target:debian13-jdk25", distrib = "deps/tomcat11" }
  dockerfile-inline = <<-EOF
    ${base("base")}

    ${run_debian13("install-tomcat.sh", true, ["TOMCAT_MAJOR_VERSION=11"])}

    ENTRYPOINT ["/tomcat"]
  EOF
}

target "debian13-jdk21-keycloak2" {
  attest = ["type=sbom", "type=provenance,mode=max"]
  tags = tags("debian13-jdk21-keycloak2")
  contexts = { scripts = "scripts", base = "target:debian13-jdk21", distrib = "deps/keycloak2" }
  dockerfile-inline = <<-EOF
    ${base("base")}

    ${run_debian13("install-keycloak.sh", true, [])}

    ENTRYPOINT ["/keycloak"]
  EOF
}

target "debian13-jdk25-keycloak2" {
  attest = ["type=sbom", "type=provenance,mode=max"]
  tags = tags("debian13-jdk25-keycloak2")
  contexts = { scripts = "scripts", base = "target:debian13-jdk25", distrib = "deps/keycloak2" }
  dockerfile-inline = <<-EOF
    ${base("base")}

    ${run_debian13("install-keycloak.sh", true, [])}

    ENTRYPOINT ["/keycloak"]
  EOF
}

# monitoring

target "debian13-monitoring-prometheus" {
  attest = ["type=sbom", "type=provenance,mode=max"]
  tags = tags("debian13-monitoring-prometheus")
  contexts = { scripts = "scripts", base = "target:debian13", distrib = "deps/prometheus" }
  dockerfile-inline = <<-EOF
    ${base("base")}

    ${run_debian13("install-monitoring-prometheus.sh", true, [])}

    ENTRYPOINT ["/prometheus"]
  EOF
}

target "debian13-monitoring-alertmanager" {
  attest = ["type=sbom", "type=provenance,mode=max"]
  tags = tags("debian13-monitoring-alertmanager")
  contexts = { scripts = "scripts", base = "target:debian13", distrib = "deps/alertmanager" }
  dockerfile-inline = <<-EOF
    ${base("base")}

    ${run_debian13("install-monitoring-alertmanager.sh", true, [])}

    ENTRYPOINT ["/alertmanager"]
  EOF
}

target "debian13-monitoring-grafana" {
  attest = ["type=sbom", "type=provenance,mode=max"]
  tags = tags("debian13-monitoring-grafana")
  contexts = { scripts = "scripts", base = "target:debian13", distrib = "deps/grafana" }
  dockerfile-inline = <<-EOF
    ${base("base")}

    ${run_debian13("install-monitoring-grafana.sh", true, [])}

    ENTRYPOINT ["/grafana"]
  EOF
}

target "debian13-monitoring-cadvisor" {
  attest = ["type=sbom", "type=provenance,mode=max"]
  tags = tags("debian13-monitoring-cadvisor")
  contexts = { scripts = "scripts", base = "target:debian13", distrib = "deps/cadvisor" }
  dockerfile-inline = <<-EOF
    ${base("base")}

    ${run_debian13("install-monitoring-cadvisor.sh", true, [])}

    ENTRYPOINT ["/monitoring-cadvisor"]
  EOF
}

target "debian13-monitoring-postgres" {
  attest = ["type=sbom", "type=provenance,mode=max"]
  tags = tags("debian13-monitoring-postgres")
  contexts = { scripts = "scripts", base = "target:debian13", distrib = "deps/postgres-exporter" }
  dockerfile-inline = <<-EOF
    ${base("base")}

    ${run_debian13("install-monitoring-postgres.sh", true, [])}

    ENTRYPOINT ["/monitoring-postgres"]
  EOF
}

target "debian13-monitoring-nginx" {
  attest = ["type=sbom", "type=provenance,mode=max"]
  tags = tags("debian13-monitoring-nginx")
  contexts = { scripts = "scripts", base = "target:debian13", distrib = "deps/nginx-exporter" }
  dockerfile-inline = <<-EOF
    ${base("base")}

    ${run_debian13("install-monitoring-nginx.sh", true, [])}

    ENTRYPOINT ["/monitoring-nginx"]
  EOF
}

target "debian13-monitoring-host" {
  attest = ["type=sbom", "type=provenance,mode=max"]
  tags = tags("debian13-monitoring-host")
  contexts = { scripts = "scripts", base = "target:debian13", distrib = "deps/node-exporter" }
  dockerfile-inline = <<-EOF
    ${base("base")}

    ${run_debian13("install-monitoring-host.sh", true, [])}

    ENTRYPOINT ["/monitoring-host"]
  EOF
}

target "debian13-monitoring-tempo" {
  attest = ["type=sbom", "type=provenance,mode=max"]
  tags = tags("debian13-monitoring-tempo")
  contexts = { scripts = "scripts", base = "target:debian13", distrib = "deps/tempo" }
  dockerfile-inline = <<-EOF
    ${base("base")}

    ${run_debian13("install-monitoring-tempo.sh", true, [])}

    ENTRYPOINT ["/tempo"]
  EOF
}

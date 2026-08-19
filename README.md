# docker-machines

Docker build recipes for [optionfactory](https://github.com/optionfactory) infrastructure images, based on Debian 13 (trixie).

Images are published to [Docker Hub](https://hub.docker.com/u/optionfactory) with a numeric tag (`232` at the time of writing) and `latest`.

## Images

### Base

| Image | Contents |
|---|---|
| `optionfactory/debian13` | Debian trixie + ca-certificates, minimal baseline for all other images |

### Runtimes

| Image | Contents |
|---|---|
| `optionfactory/debian13-jdk21` | Amazon Corretto 21 |
| `optionfactory/debian13-jdk25` | Amazon Corretto 25 |
| `optionfactory/debian13-postgres15` | PostgreSQL 15 + Patroni (optional) |
| `optionfactory/debian13-postgres16` | PostgreSQL 16 + Patroni (optional) |
| `optionfactory/debian13-postgres17` | PostgreSQL 17 + Patroni (optional) |
| `optionfactory/debian13-postgres18` | PostgreSQL 18 + Patroni (optional) |
| `optionfactory/debian13-mariadb12` | MariaDB 12 |
| `optionfactory/debian13-etcd3` | etcd 3.x |

### Application servers

| Image | Contents |
|---|---|
| `optionfactory/debian13-jdk{21,25}-tomcat9` | Tomcat 9 |
| `optionfactory/debian13-jdk{21,25}-tomcat10` | Tomcat 10.1 |
| `optionfactory/debian13-jdk{21,25}-tomcat11` | Tomcat 11 |
| `optionfactory/debian13-jdk{21,25}-keycloak2` | Keycloak 26 + [optionfactory-keycloak](https://github.com/optionfactory/keycloak) modules |
| `optionfactory/debian13-jdk25-sonarqube10` | SonarQube |

Services run as dedicated non-root users via `setpriv`; init steps (initdb, volume chowns) run as root.

### Web servers / proxies

| Image | Contents |
|---|---|
| `optionfactory/debian13-nginx130` | nginx 1.30 + [nginx-remove-server-header-module](https://github.com/optionfactory/nginx-remove-server-header-module) + [legopfa](https://github.com/optionfactory/legopfa) (Let's Encrypt via acme module) |
| `optionfactory/debian13-caddy2` | Caddy 2 |

### Tools

| Image | Contents |
|---|---|
| `optionfactory/debian13-jdk{21,25}-builder` | JDK + Maven 3, CI builder image |
| `optionfactory/debian13-barman2` | [Barman](https://pgbarman.org/) PostgreSQL backup manager |
| `optionfactory/debian13-journal-webd` | [journal-webd](https://github.com/optionfactory/journal-webd), exposes the systemd journal over HTTP |
| `optionfactory/debian13-medic` | network diagnostics toolbox (ping, traceroute, tcpdump, ...) |
| `optionfactory/sloth` | [sloth](https://github.com/optionfactory/sloth), static binary in a `FROM scratch` image |

## Monitoring

Prometheus metrics stack and exporters.

### optionfactory/debian13-monitoring-host

> This container needs to run with --network host.  
> This container needs to run with --pid host.  

Runs [node_exporter](https://github.com/prometheus/node_exporter).  
Default port is `localhost:9100`.  
Prometheus endpoint is `/metrics`.  

example: 
```bash 
docker run -d --rm \
  --name monitoring-host \
  --network host \
  --pid host \
  --volume=/:/host:ro,rslave \
  optionfactory/debian13-monitoring-host \
  --path.rootfs=/host
```

### optionfactory/debian13-monitoring-cadvisor

> This container needs to run with `--privileged`.  

Runs [cAdvisor](https://github.com/google/cadvisor).  
Default port is `8080`.  
Prometheus endpoint is `/metrics`.  

example:
```bash
docker run -d --rm \
  --name monitoring-cadvisor \
  --network monitoring \
  --ip 172.17.xxx.101 \
  --privileged \
  --device=/dev/kmsg \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:ro \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/docker/:/var/lib/docker:ro \
  --volume=/dev/disk/:/dev/disk:ro \
  optionfactory/debian13-monitoring-cadvisor
```

### optionfactory/debian13-monitoring-nginx

Runs [nginx-prometheus-exporter](https://github.com/nginxinc/nginx-prometheus-exporter).  
Default port is `9113`.  
Prometheus endpoint is `/metrics`.  

example:
```bash
docker run -d --rm \
    --name monitoring-host \
    --network monitoring \
    --ip 172.18.xxx.100 \
    optionfactory/debian13-monitoring-nginx \
    --nginx.scrape-uri=http://172.17.0.1/stub-status 
```

### optionfactory/debian13-monitoring-postgres

Runs [postgres_exporter](https://github.com/prometheus-community/postgres_exporter).  
Default port is `9187`.  
Prometheus endpoint is `/metrics`.  

example:
```bash

docker run -d --rm \
    --name monitoring-postgres \
    --network monitoring \
    --ip 172.18.xxx.100 \
    -e DATA_SOURCE_URI="localhost:5432/?sslmode=disable" \
    -e DATA_SOURCE_USER="postgres" \
    -e DATA_SOURCE_PASS="postgres" \
    optionfactory/debian13-monitoring-postgres

```

### Other monitoring images

| Image | Contents |
|---|---|
| `optionfactory/debian13-monitoring-prometheus` | [Prometheus](https://github.com/prometheus/prometheus) |
| `optionfactory/debian13-monitoring-alertmanager` | [Alertmanager](https://github.com/prometheus/alertmanager) |
| `optionfactory/debian13-monitoring-grafana` | [Grafana](https://github.com/grafana/grafana) |
| `optionfactory/debian13-monitoring-tempo` | [Tempo](https://github.com/grafana/tempo) |

## Building

Requirements: `make`, `docker` with the containerd snapshotter (buildkit image store), the `docker buildx` plugin, `curl`, `jq`, `unzip`, `python3-venv` (for the test suite, a `.venv` is created on demand).

```bash
make check-updates              # compares pinned versions with upstream releases
make build                      # builds all images (docker buildx bake, parallel siblings)
make build-optionfactory-debian13-jdk25-tomcat11   # builds one image and its parents
make test                       # smoke-tests all built images (pytest)
make clean-deps                 # removes cached deps/ downloads
make publish                    # builds, tests, then pushes TAG_VERSION and latest to Docker Hub
```

Tests live in `test/`: `test_images.py` is a parametrized table exercising every image through its real binaries (version/content assertions, major-version level so pin bumps don't break it); `test_boot.py` boots postgres/tomcat/sloth with their real entrypoints and asserts readiness log lines, HTTP responses, and running state. `make publish` runs the suite between building and pushing.

Versions are pinned as Makefile variables. `docker buildx bake` (driven by the make wrappers) builds the whole graph: `docker-bake.hcl` defines one target per image, renders its Dockerfile inline (`dockerfile-inline`, no per-image Dockerfiles or directories), links each image to its parent via `contexts.base = "target:<parent>"` + `FROM base`, and mounts exactly the artifacts each image needs from `deps/<family>/` via named build contexts (`distrib`), plus the shared installer scripts (`scripts/`). Artifacts are downloaded into per-family directories on demand and re-downloaded whenever a pinned version changes; nothing is ever copied around.

To publish to ghcr.io instead (emergency fallback), uncomment the `ghcr.io` tags in `docker-bake.hcl`, `docker login ghcr.io`, and run the `publish-github` target (commented out in the Makefile).

## Conventions

- **Privileges**: Dockerfiles do not declare `USER`. Entrypoints start as root to perform init (chowns, initdb, certificate renewal), then drop to a dedicated user with `exec setpriv --reuid=<service> --regid=docker-machines --init-groups`. This mirrors the official postgres/mariadb images and allows volume permissions to be fixed at startup.
- **Shared ids**: every service account uses uid/gid 950, group `docker-machines`, so containers can share volumes regardless of the image they come from.
- **deps flow**: `deps/<family>/` at the repo root caches downloaded artifacts, one directory per artifact family, containing exactly what the family's images need. Dockerfiles read them directly through named build contexts (`--mount=type=bind,from=distrib,target=/build`); install scripts are mounted from `scripts/` and executed as `/build-scripts/install-*.sh`. Editing a script takes effect on the next build — there is no sync step. Bumping a pinned version wipes and re-downloads the family directory (`.stamp-<version>` files). Corretto JDKs are pinned (`CORRETTO2x_VERSION`) and checked by `make check-updates` via the corretto.aws `latest` redirect.
- **Tagging**: all images share one monotonically increasing `TAG_VERSION` (plus `latest`), bumped together with the version pins in the same commit. `make check-updates` compares the pins against upstream releases.
- **Naming**: image suffixes lock the packaged major version (e.g. `keycloak2`, `nginx130`, `postgres15`-`postgres18`, `mariadb12`); breaking upgrades get a new bake target/image name rather than overwriting the suffix.
- **Build requirements**: docker must use the containerd snapshotter (checked by `verify-docker-backend`), because images are built with SBOM attestations. Dockerfiles live inline in `docker-bake.hcl` and use `FROM base`, resolved by bake — always build through the make/bake entry points, not standalone `docker build`.

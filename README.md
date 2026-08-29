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
| `optionfactory/debian13-mysql8` | MySQL 8.4 (LTS, from repo.mysql.com) |
| `optionfactory/debian13-mysql9` | MySQL 9 (LTS, from repo.mysql.com) |
| `optionfactory/debian13-etcd3` | etcd 3.x |

### Application servers

| Image | Contents |
|---|---|
| `optionfactory/debian13-jdk{21,25}-tomcat9` | Tomcat 9 |
| `optionfactory/debian13-jdk{21,25}-tomcat10` | Tomcat 10.1 |
| `optionfactory/debian13-jdk{21,25}-tomcat11` | Tomcat 11 |
| `optionfactory/debian13-jdk{21,25}-keycloak2` | Keycloak 26 + [optionfactory-keycloak](https://github.com/optionfactory/keycloak) modules |
| `optionfactory/debian13-jdk25-sonarqube10` | SonarQube |

Services run as dedicated non-root users via `setpriv`; init steps (initdb, bootstrap scripts) run as root.

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

## Databases

`debian13-mysql8`, `debian13-mysql9`, `debian13-mariadb12` and `debian13-postgres{15,16,17,18}` share the same bootstrap model.

### Volumes

| Image | Data directory | Init scripts |
|---|---|---|
| `mysql8`, `mysql9`, `mariadb12` | `/var/lib/mysql` | `/sql-init.d/` |
| `postgres15`-`postgres18` | `/var/lib/postgresql/data` | `/sql-init.d/` (config in `/var/lib/postgresql/conf/`) |

Both paths are declared as `VOLUME`s. The data directory must be writable by uid/gid `950` (`docker-machines`): the entrypoints do **not** chown it at startup, so with a bind mount either pre-create the directory with that ownership or remap ids (e.g. pinch `remap_ids: ["me:950"]`).

### First start

When the data directory is empty the entrypoint bootstraps it, then starts the real server. The init phase is a one-off: on subsequent starts the scripts in `/sql-init.d/` are **not** re-run.

1. Initialize the data directory (`mysqld --initialize-insecure`, `mariadb-install-db --skip-test-db`, `initdb`), running as the service user.
2. Start a temporary server with networking disabled (`--skip-networking` / `listen_addresses=127.0.0.1`).
3. Run every file in `/sql-init.d/`, in lexical order, connecting over the unix socket as the local superuser:
   - `*.sql` — piped to the client (`mysql -uroot` / `mariadb -uroot` / `psql -U postgres`)
   - `*.sql.gz` — gunzipped and piped
   - `*.sh` — sourced into the entrypoint shell (runs as root; `"${mysql_client[@]}"` / `"${psql[@]}"` are available)
4. Stop the temporary server and `exec` the real one as uid 950.

Any failing statement or script aborts the init (`bash -e`, `psql -v ON_ERROR_STOP=1`): the container exits with status 1, later files are not run, and statements before the failing one have already been applied. Since "initialized" is detected only by the presence of `/var/lib/mysql/mysql` (or `PG_VERSION`), the next start would skip the init phase on a half-populated volume — wipe the data directory and start again.

### Default accounts

Images ship **no** files in `/sql-init.d/` and create **no** network-reachable account. Right after initialization the only accounts are the ones the upstream initializer creates:

| Image | Accounts after init | Reachable from |
|---|---|---|
| mysql8 / mysql9 | `root@localhost` (empty password), `mysql.sys`, `mysql.session`, `mysql.infoschema` (locked) | unix socket / TCP from inside the container only |
| mariadb12 | `root@localhost` (`unix_socket` auth), `mariadb.sys@localhost` (locked, no privileges) | unix socket, as OS user `root` |
| postgres | `postgres` superuser, no password | as allowed by the mounted `pg_hba.conf` |

There is no `test` database (`mysqld --initialize` never creates one; MariaDB is initialized with `--skip-test-db`, which also skips the anonymous `PUBLIC` grants on `test%`).

Environment variables such as `MYSQL_ROOT_PASSWORD`, `MYSQL_DATABASE`, `POSTGRES_PASSWORD` are **not** honored — these are not the official images. Creating application users and databases is the job of the mounted init scripts, e.g. `/sql-init.d/00_users.sql` for mysql/mariadb:

```sql
CREATE USER 'root'@'%' IDENTIFIED BY 'password' ;
GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION ;
CREATE DATABASE app ;
```

Mounting a directory on `/sql-init.d/` replaces its contents entirely, which is why the images keep nothing there: anything baked into that path would be hidden by the mount.

### Granting access

Scripts run in lexical order, so put role/user creation in a file that sorts before the schema dumps (e.g. `000_users.sql`, then `00_init_app.sql`).

**mysql / mariadb**: `CREATE USER` alone gives only `USAGE` (login, nothing else) — always pair it with a `GRANT`. Global grants (`ON *.*`) and database-level grants (`ON app.*`) are matched by name at check time, so they can be issued before the database exists.

**postgres**: `pg_hba.conf` (mounted in `/var/lib/postgresql/conf/`) decides *who can connect as which role from where*; grants and ownership decide *what the role can do*. `GRANT ... ON DATABASE x` requires `x` to exist, and there is no `*.*` wildcard. To prepare access for databases created by later scripts, either:

- make the role the owner: `CREATE DATABASE app OWNER approle;` (or grant the role membership in a NOLOGIN owner role beforehand) — owners need no further grants;
- give it `CREATEDB` and let it create its own databases;
- grant in `template1` (`GRANT ALL ON SCHEMA public TO approle; ALTER DEFAULT PRIVILEGES ...`), which is cloned by every later `CREATE DATABASE` — but **not** by `pg_dump` output, which uses `TEMPLATE = template0`.

Restored `pg_dump` files carry their own `OWNER TO` / `GRANT` statements: the roles they reference must exist before the dump runs. Note that `psql -c "A; B"` executes both statements in one transaction, so a failing `GRANT` also rolls back the `CREATE ROLE` before it.

### Logging

Everything goes to the container's stderr, nothing to tables or files in the data volume:

| Image | Error log | Slow queries | Statement log |
|---|---|---|---|
| mysql / mariadb | stderr (default) | `slow_query_log=1`, `long_query_time=3` | `general_log=0`; enable at runtime with `SET GLOBAL general_log=1` |
| postgres | `log_destination=stderr`, `logging_collector=off` | `log_min_duration_statement=10000` | `log_statement` (off by default) |

MySQL and MariaDB cannot write query logs to the container's stderr directly (mysqld only accepts regular files; mariadbd gets `Permission denied` on docker's pipes and `ESPIPE` on a TTY), so `log_output=FILE` points the slow and general logs at `/var/run/mysqld/{slow,general}.log` — in the container layer, not the data volume — and the server is run through [docker-snitch](https://github.com/optionfactory/docker-heist/tree/master/crates/docker-snitch), which provisions those files, relays their content to stderr as it is written, and removes the relayed part from the files in place, losslessly (`fallocate` collapse-range on ext4/xfs; punch-hole, leaving a sparse file, on btrfs/zfs/tmpfs; a filesystem supporting neither makes the container refuse to start). `/var/run/mysqld` is in the container layer, i.e. overlayfs forwarding `fallocate` to the filesystem under Docker's data root, so that filesystem is what matters: ext4/xfs/btrfs/zfs/NFSv4.2 all work; a data root on vfat or on NFS before v4.2 does not — see the [docker-snitch README](https://github.com/optionfactory/docker-heist/tree/master/crates/docker-snitch#filesystem-requirements). It also forwards signals to the server, reaps orphaned processes, and exits with the server's status.

### Process model

Entrypoints start as root only to run the bootstrap above; the server itself is started with `exec setpriv --reuid=<mysql|postgres> --regid=docker-machines --init-groups` and runs as uid/gid `950:950`. The daemons' own `--user` switches are not used, so file ownership is uniform across images regardless of which groups the distro packages created. Postgres is PID 1; in the mysql/mariadb containers PID 1 is `docker-snitch` (same uid, no capabilities) with the server as its only child (see [Logging](#logging)).

## Building

Requirements: `make`, `docker` configured as described below, `curl`, `jq`, `unzip`, `python3-venv` (for the test suite, a `.venv` is created on demand).

### Docker configuration

Every bake target is built with `attest = ["type=sbom", "type=provenance,mode=max"]`, so each image is a multi-manifest index (image + attestation manifests). The classic `overlay2` image store cannot hold those, so the docker daemon **must** use the containerd image store (containerd snapshotter). `make build`/`test`/`publish` refuse to run otherwise (`verify-docker-backend`).

1. Check what the daemon is using:

   ```bash
   docker info --format '{{.Driver}} {{json .DriverStatus}}'
   # ok:  overlayfs [["driver-type","io.containerd.snapshotter.v1"]]
   # bad: overlay2 [["Backing Filesystem","extfs"],...]
   ```

   Docker Engine ≥ 29 enables the containerd store by default on fresh installs, so a new machine usually needs nothing. Installs upgraded from older versions keep `overlay2` and need step 2.

2. If needed, enable it in `/etc/docker/daemon.json` (create the file if missing) and restart the daemon:

   ```json
   {
     "features": {
       "containerd-snapshotter": true
     }
   }
   ```

   ```bash
   sudo systemctl restart docker
   ```

   Switching image store hides the images, containers and volumes of the old store (they stay on disk and reappear if you switch back), so re-pull/rebuild what you need afterwards. Do not flip it back and forth casually.

3. Make sure the `buildx` plugin is installed and the **default** builder (driver `docker`) is selected:

   ```bash
   docker buildx version          # e.g. github.com/docker/buildx v0.36.x
   docker buildx ls               # default* ... DRIVER docker
   ```

   On Debian/Ubuntu the plugin is the `docker-buildx-plugin` package from Docker's apt repo. Do **not** create a `docker-container` builder for this repo: bake relies on the default `docker` driver so that built images land straight in the local image store (where `make test` finds them and `make publish` pushes them from). If you previously ran `docker buildx create --use`, switch back with `docker buildx use default`.

4. For `make publish`, log in with an account that can push to the `optionfactory` Docker Hub organisation:

   ```bash
   docker login
   ```

`make verify-docker-backend` re-runs the check from step 1 (it is also a prerequisite of every build/test/publish target).

### Make targets

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

- **Privileges**: Dockerfiles do not declare `USER`. Entrypoints start as root to perform init (initdb, bootstrap scripts, certificate renewal), then drop to a dedicated user with `exec setpriv --reuid=<service> --regid=docker-machines --init-groups`. Entrypoints do not chown volumes: mounted data directories must already be owned by uid/gid 950 (see [Databases](#databases)).
- **Shared ids**: every service account uses uid/gid 950, group `docker-machines`, so containers can share volumes regardless of the image they come from.
- **deps flow**: `deps/<family>/` at the repo root caches downloaded artifacts, one directory per artifact family, containing exactly what the family's images need. Dockerfiles read them directly through named build contexts (`--mount=type=bind,from=distrib,target=/build`); install scripts are mounted from `scripts/` and executed as `/build-scripts/install-*.sh`. Editing a script takes effect on the next build — there is no sync step. Bumping a pinned version wipes and re-downloads the family directory (`.stamp-<version>` files). Corretto JDKs are pinned (`CORRETTO2x_VERSION`) and checked by `make check-updates` via the corretto.aws `latest` redirect.
- **Tagging**: all images share one monotonically increasing `TAG_VERSION` (plus `latest`), bumped together with the version pins in the same commit. `make check-updates` compares the pins against upstream releases.
- **Naming**: image suffixes lock the packaged major version (e.g. `keycloak2`, `nginx130`, `postgres15`-`postgres18`, `mariadb12`); breaking upgrades get a new bake target/image name rather than overwriting the suffix.
- **Build requirements**: docker must use the containerd snapshotter (checked by `verify-docker-backend`, see [Docker configuration](#docker-configuration)), because images are built with SBOM attestations. Dockerfiles live inline in `docker-bake.hcl` and use `FROM base`, resolved by bake — always build through the make/bake entry points, not standalone `docker build`.

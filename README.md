# Monitoring

Prometheus metrics exporters

## optionfactory/debian12-monitoring-host

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
  optionfactory/debian12-monitoring-host \
  --path.rootfs=/host
```

## optionfactory/debian12-monitoring-cadvisor

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
  optionfactory/debian12-monitoring-cadvisor
```

## optionfactory/debian12-monitoring-nginx

Runs [nginx-prometheus-exporter](https://github.com/nginxinc/nginx-prometheus-exporter).  
Default port is `9113`.  
Prometheus endpoint is `/metrics`.  

example:
```bash
docker run -d --rm \
    --name monitoring-host \
    --network monitoring \
    --ip 172.18.xxx.100 \
    optionfactory/debian12-monitoring-nginx \
    --nginx.scrape-uri=http://172.17.0.1/stub-status 
```

## optionfactory/debian12-monitoring-postgres

Runs [postgres_exporter](https://github.com/prometheus-community/postgres_exporter).  
Default port is `9187`.  
Promethues endpoint is `/metrics`.  

example:
```bash

docker run -d --rm \
    --name monitoring-postgres \
    --network monitoring \
    --ip 172.18.xxx.100 \
    -e DATA_SOURCE_URI="localhost:5432/?sslmode=disable" \
    -e DATA_SOURCE_USER="postgres" \
    -e DATA_SOURCE_PASS="postgres" \
    optionfactory/debian12-monitoring-postgres
    

```
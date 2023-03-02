#!/bin/bash -e

echo "Installing Sonarqube"
mkdir -p /opt/sonarqube
cp -R /tmp/sonarqube-*/* /opt/sonarqube
chmod +x /opt/sonarqube/elasticsearch/bin/elasticsearch

groupadd --system --gid 20000 docker-machines
useradd --system --create-home --gid docker-machines --uid 20000 sonarqube
chown -R sonarqube:docker-machines /opt/sonarqube


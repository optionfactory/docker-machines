#!/bin/bash -e


case "${DISTRIB_LABEL}" in
    debian*|ubuntu*)
        DEBIAN_FRONTEND=noninteractive apt-get -y -q update
        DEBIAN_FRONTEND=noninteractive apt-get -y -q --no-install-recommends install systemd-journal-remote
        DEBIAN_FRONTEND=noninteractive apt-get -y -q autoclean
        DEBIAN_FRONTEND=noninteractive apt-get -y -q autoremove
        rm -rf /var/lib/apt/lists/*
    ;;
    rocky9)
        yum install -q -y systemd-journal-remote
        yum clean all
        rm -rf /var/cache/yum
    ;;
    *)
    echo "distribution ${DISTRIB_LABEL} not supported"
    exit 1
    ;;
esac

mkdir -p /journal-remote-conf/
mkdir -p /journal-remote-logs/

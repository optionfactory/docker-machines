#!/bin/bash -e


if [ $# -eq 1 -a "$1" = "help" ]; then
    echo "gen scm-service scm-team project-name"
    echo "help"
    exit 0
fi

if [ $# -eq 4 -a "$1" = "gen" ]; then
    sed "s/{{SCM_SERVICE}}/${2}/g;s/{{SCM_TEAM}}/${3}/g;s/{{PROJECT}}/${4}/g" /project-makefile.tpl
    exit 0
fi

if [ $# -gt 0 -a "$1" = "gen" ]; then
    echo "usage: gen scm-service scm-team project-name"
    exit 1
fi


if [ $# -ne 0 ]; then
    exec "$@"
fi

exec bash

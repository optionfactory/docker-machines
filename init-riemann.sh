#!/bin/bash -e

if [ $# -eq 0 ]; then
    exec gosu riemann:riemann /opt/riemann/bin/riemann /opt/riemann.config
fi

exec "$@"

#!/bin/bash -e

if [ $# -eq 0 ]; then
    exec python3 /restalpr.py
fi

exec "$@"

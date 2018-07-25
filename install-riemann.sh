#!/bin/bash

groupadd -r riemann 
useradd -r -m -g riemann riemann
mv /tmp/riemann-* /opt/riemann
cp /opt/riemann/etc/riemann.config /opt/riemann.config
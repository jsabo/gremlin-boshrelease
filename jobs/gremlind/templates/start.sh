#!/bin/bash
set -eo pipefail

# render config
cp <%= p("template_dir") %>/config.yaml /etc/gremlin/config.yaml

# start gremlind under Monit
exec /var/vcap/packages/gremlin/sbin/gremlind \
     --config /etc/gremlin/config.yaml \
     --pidfile /var/vcap/sys/run/gremlind/gremlind.pid

#!/bin/bash
set -e
pidfile=/var/vcap/sys/run/gremlind/gremlind.pid
[ -f $pidfile ] && kill "$(cat $pidfile)"


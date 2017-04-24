#!/bin/bash

debug0 "Processing ${DOCKER_ENTRYPOINT:-$0}"

# Redirect lighttpd logs to Docker console
# - https://redmine.lighttpd.net/issues/2731#note-15
# - https://github.com/docker/docker/issues/6880#issuecomment-170214851
if [ ! -e /tmp/stdout.log ]; then
  info "Redirecting access log to stdout"
  mkfifo -m 600 /tmp/stdout.log
  chown lighttpd:lighttpd /tmp/stdout.log
  cat <> /tmp/stdout.log &
fi
if [ ! -e /tmp/stderr.log ]; then
  info "Redirecting error log to stderr"
  mkfifo -m 600 /tmp/stderr.log
  chown lighttpd:lighttpd /tmp/stderr.log
  cat <> /tmp/stderr.log 1>&2 &
fi

#!/bin/bash

################################################################################

# Redirect lighttpd logs to Docker console
# - https://redmine.lighttpd.net/issues/2731#note-15
# - https://github.com/docker/docker/issues/6880#issuecomment-170214851
if [ ! -e /tmp/stdout.log ]; then
  info "Creating stdout redirector /tmp/stdout.log"
  mkfifo -m 600 /tmp/stdout.log
  chown ${LIGHTTPD_FILE_OWNER} /tmp/stdout.log
  cat <> /tmp/stdout.log &
fi
if [ ! -e /tmp/stderr.log ]; then
  info "Creating stderr redirector /tmp/stderr.log"
  mkfifo -m 600 /tmp/stderr.log
  chown ${LIGHTTPD_FILE_OWNER} /tmp/stderr.log
  cat <> /tmp/stderr.log 1>&2 &
fi

################################################################################

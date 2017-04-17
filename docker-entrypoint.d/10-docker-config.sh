#!/bin/bash

debug0 "Processing $(basename ${DOCKER_ENTRYPOINT:-$0})"

# Docker entrypoint configuration
DOCKER_COMMAND=lighttpd
DOCKER_USER=lighttpd

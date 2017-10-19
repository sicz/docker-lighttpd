#!/bin/bash -e

################################################################################

# Lighttpd user, group and file owner
export LIGHTTPD_USER=lighttpd
export LIGHTTPD_GROUP=${LIGHTTPD_USER}
LIGHTTPD_FILE_OWNER="${LIGHTTPD_USER}:${LIGHTTPD_GROUP}"

# Lighttpd requires the certificate and the key to be together in one file,
# so the server certificate should be placed in a private directory
: ${SERVER_CRT_DIR:=/etc/ssl/private}

# Server certificate, private key and passphrase files owner
: ${SERVER_KEY_FILE_USER:=${LIGHTTPD_USER}}
: ${SERVER_KEY_FILE_GROUP:=${LIGHTTPD_GROUP}}
: ${SERVER_CRT_FILE_USER:=${LIGHTTPD_USER}}
: ${SERVER_CRT_FILE_GROUP:=${LIGHTTPD_GROUP}}

# Lighttpd requires the certificate and the key to be together in one file,
# so the server certificate should not be readable by others
: ${SERVER_CRT_FILE_MODE:=440}

# TODO Lighttpd does not support encrypted private key
# # Set default server private key passphrase file location
# if [ -e /run/secrets/server.pwd ]; then
#   : ${SERVER_KEY_PWD_FILE:=/run/secrets/server.pwd}
# else
#   : ${SERVER_KEY_PWD_FILE:=${SERVER_KEY_DIR}/server.pwd}
# fi

# Redirect logs to the Docker console
DOCKER_LOG_FILE_OWNER="${LIGHTTPD_FILE_OWNER}"
DOCKER_LOG_FILE="/var/log/docker.log"
DOCKER_ERR_FILE="/var/log/docker.err"

################################################################################

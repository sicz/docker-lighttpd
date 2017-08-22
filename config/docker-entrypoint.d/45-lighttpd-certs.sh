#!/bin/bash -e

################################################################################

# Lighttpd requires the certificate and the key to be together in one file
if [ -e ${SERVER_CRT_FILE} -a -e ${SERVER_KEY_FILE} ]; then
  info "Creating lighttpd server certificate file"
  openssl rsa -in ${SERVER_KEY_FILE} -passin pass:${SERVER_KEY_PWD} >> ${SERVER_CRT_FILE}
  chown lighttpd:lighttpd ${SERVER_CRT_FILE}
  chmod 640 ${SERVER_CRT_FILE}
  rm -f ${SERVER_KEY_FILE}
fi

################################################################################

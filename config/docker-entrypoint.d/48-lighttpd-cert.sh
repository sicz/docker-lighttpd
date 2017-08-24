#!/bin/bash -e

################################################################################

# Lighttpd requires the certificate and the key to be together in one file
# TODO Lighttpd does not support encrypted private key
if [ -e ${SERVER_CRT_FILE} -a -e ${SERVER_KEY_FILE} ]; then
  info "Creating lighttpd certificate file ${SERVER_CRT_FILE}"
  openssl rsa -in ${SERVER_KEY_FILE} -passin pass:${SERVER_KEY_PWD} >> ${SERVER_CRT_FILE}
  chown lighttpd:lighttpd ${SERVER_CRT_FILE}
  rm -f ${SERVER_KEY_FILE}
elif [ -e ${SERVER_CRT_FILE} ]; then
  info "Using lighttpd certificate file ${SERVER_CRT_FILE}"
fi

################################################################################

# Export variables for /etc/lighttpd/server.conf
export CA_CRT_FILE SERVER_CRT_FILE

################################################################################

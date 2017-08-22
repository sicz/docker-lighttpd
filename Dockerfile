ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ARG DOCKER_IMAGE_NAME
ARG DOCKER_IMAGE_TAG
ARG DOCKER_PROJECT_DESC
ARG DOCKER_PROJECT_URL
ARG BUILD_DATE
ARG GITHUB_URL
ARG VCS_REF

LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.name="${DOCKER_IMAGE_NAME}"
LABEL org.label-schema.version="${DOCKER_IMAGE_TAG}"
LABEL org.label-schema.description="${DOCKER_PROJECT_DESC}"
LABEL org.label-schema.url="${DOCKER_PROJECT_URL}"
LABEL org.label-schema.vcs-url="${GITHUB_URL}"
LABEL org.label-schema.vcs-ref="${VCS_REF}"
LABEL org.label-schema.build-date="${BUILD_DATE}"

RUN set -exo pipefail; \
  adduser -D -H -u 1000 lighttpd; \
  apk add --no-cache \
    lighttpd \
    lighttpd-mod_auth \
    ; \
  mkdir -p \
    /var/www \
    /var/cache/lighttpd \
    /var/lib/lighttpd \
    /var/log/lighttpd \
    ; \
  rm -rf /var/www/*; \
  chown lighttpd:lighttpd \
    /var/cache/lighttpd \
    /var/lib/lighttpd \
    /var/log/lighttpd \
    ; \
  chmod 750 \
    /var/cache/lighttpd \
    /var/lib/lighttpd \
    /var/log/lighttpd \
    ; \
  lighttpd -v

COPY config /

# Lighttpd requires the certificate and the key to be together in one file,
# so the server certificate must be placed in a private directory
ENV SERVER_CRT_DIR=/etc/ssl/private
ENV CA_CRT_FILE=/etc/ssl/certs/ca_crt.pem

ENV DOCKER_COMMAND=/usr/sbin/lighttpd
CMD ["-D", "-f", "/etc/lighttpd/lighttpd.conf"]

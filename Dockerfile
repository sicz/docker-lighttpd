ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ARG DOCKER_IMAGE_NAME
ARG DOCKER_IMAGE_TAG
ARG DOCKER_PROJECT_DESC
ARG DOCKER_PROJECT_URL
ARG BUILD_DATE
ARG GITHUB_URL
ARG VCS_REF

LABEL \
  org.label-schema.schema-version="1.0" \
  org.label-schema.name="${DOCKER_IMAGE_NAME}" \
  org.label-schema.version="${DOCKER_IMAGE_TAG}" \
  org.label-schema.description="${DOCKER_PROJECT_DESC}" \
  org.label-schema.url="${DOCKER_PROJECT_URL}" \
  org.label-schema.vcs-url="${GITHUB_URL}" \
  org.label-schema.vcs-ref="${VCS_REF}" \
  org.label-schema.build-date="${BUILD_DATE}"

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

ENV DOCKER_COMMAND=/usr/sbin/lighttpd
CMD ["-D", "-f", "/etc/lighttpd/lighttpd.conf"]

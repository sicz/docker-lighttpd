ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ARG LIGHTTPD_VERSION

ENV \
  DOCKER_COMMAND="/usr/sbin/lighttpd" \
  LIGHTTPD_VERSION="${LIGHTTPD_VERSION}"

RUN set -exo pipefail; \
  adduser -D -H -u 1000 lighttpd; \
  apk add --no-cache \
    lighttpd>${LIGHTTPD_VERSION} \
    lighttpd-mod_auth>${LIGHTTPD_VERSION} \
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

COPY rootfs /

CMD ["-D", "-f", "/etc/lighttpd/lighttpd.conf"]

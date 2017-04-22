FROM sicz/baseimage-alpine:%%BASE_IMAGE_TAG%%

ENV \
  org.label-schema.schema-version="1.0" \
  org.label-schema.name="%%DOCKER_PROJECT%%/%%DOCKER_NAME%%" \
  org.label-schema.description="Lighttpd web server running in the sicz/docker-baseimage-alpine container." \
  org.label-schema.build-date="%%REFRESHED_AT%%" \
  org.label-schema.url="https://www.lighttpd.net" \
  org.label-schema.vcs-url="https://github.com/%%DOCKER_PROJECT%%/docker-%%DOCKER_NAME%%"

ENV \
  LIGHTTPD_DIR=/var/www

RUN set -x \
  && adduser -D -H -u 1000 lighttpd \
  && apk add --no-cache \
      lighttpd \
      lighttpd-mod_auth \
  && mkdir -p \
      ${LIGHTTPD_DIR} \
      /var/cache/lighttpd \
      /var/lib/lighttpd \
      /var/log/lighttpd \
  && chown lighttpd:lighttpd \
      /var/cache/lighttpd \
      /var/lib/lighttpd \
      /var/log/lighttpd \
  ;

COPY config /etc
COPY docker-entrypoint.d /docker-entrypoint.d

CMD ["lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf"]

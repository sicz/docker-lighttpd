FROM sicz/baseimage-alpine:3.6

ENV org.label-schema.schema-version="1.0"
ENV org.label-schema.name="sicz/lighttpd"
ENV org.label-schema.description="A lighttpd web server based on Alpine Linux."
ENV org.label-schema.build-date="2017-04-24T20:22:34Z"
ENV org.label-schema.url="https://www.lighttpd.net"
ENV org.label-schema.vcs-url="https://github.com/sicz/docker-lighttpd"

RUN set -x \
  && adduser -D -H -u 1000 lighttpd \
  && apk add --no-cache \
      lighttpd \
      lighttpd-mod_auth \
  && rm -rf /var/www/* \
  && mkdir -p \
      /var/www \
      /var/cache/lighttpd \
      /var/lib/lighttpd \
      /var/log/lighttpd \
  && chown lighttpd:lighttpd \
      /var/cache/lighttpd \
      /var/lib/lighttpd \
      /var/log/lighttpd \
  && lighttpd -v \
  ;

COPY config /etc
COPY docker-entrypoint.d /docker-entrypoint.d

ENV DOCKER_COMMAND=lighttpd
CMD ["lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf"]

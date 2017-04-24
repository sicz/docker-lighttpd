FROM sicz/baseimage-alpine:3.5

ENV org.label-schema.schema-version="1.0"
ENV org.label-schema.name="sicz/lighttpd"
ENV org.label-schema.description="Lighttpd web server running in the sicz/docker-baseimage-alpine container."
ENV org.label-schema.build-date="2017-04-18T20:20:49Z"
ENV org.label-schema.url="https://www.lighttpd.net"
ENV org.label-schema.vcs-url="https://github.com/sicz/docker-lighttpd"

RUN set -x \
  && adduser -D -H -u 1000 lighttpd \
  && apk add --no-cache \
      lighttpd \
      lighttpd-mod_auth \
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

EXPOSE 80

CMD ["lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf"]

FROM sicz/baseimage-alpine:3.6

ENV org.label-schema.schema-version="1.0"
ENV org.label-schema.name="sicz/lighttpd"
ENV org.label-schema.description="A lighttpd web server based on Alpine Linux."
ENV org.label-schema.build-date="2017-06-03T20:53:33Z"
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

COPY config /

ENV DOCKER_COMMAND=lighttpd
CMD ["lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf"]

FROM sicz/baseimage-alpine:%%BASE_IMAGE_TAG%%

ENV org.label-schema.schema-version="1.0"
ENV org.label-schema.name="%%DOCKER_PROJECT%%/%%DOCKER_NAME%%"
ENV org.label-schema.description="%%DOCKER_DESCRIPTION%%"
ENV org.label-schema.build-date="%%REFRESHED_AT%%"
ENV org.label-schema.url="https://www.lighttpd.net"
ENV org.label-schema.vcs-url="https://github.com/%%DOCKER_PROJECT%%/docker-%%DOCKER_NAME%%"

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

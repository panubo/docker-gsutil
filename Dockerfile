FROM docker.io/alpine:3.11

ENV \
  GSUTIL_VERSION=4.47 \
  GSUTIL_CHECKSUM=99c941dd69cf8b8b72b36f2eda29bba2c13bb9ecbaa6ebb383697ac0b355b3e6

ENV \
  GOMPLATE_VERSION=v3.6.0 \
  GOMPLATE_CHECKSUM=0867b2d6b23c70143a4ea37705d4308d051317dd0532d7f3063acec21f6cbbc8

RUN set -x \
  && apk --no-cache add python bash curl ca-certificates tar make py-crcmod lz4 xz bzip2 \
  ;

RUN set -x \
  && mkdir -p /opt \
  && curl -o /tmp/gsutil_${GSUTIL_VERSION}.tar.gz "https://storage.googleapis.com/pub/gsutil_${GSUTIL_VERSION}.tar.gz" \
  && echo "${GSUTIL_CHECKSUM}  gsutil_${GSUTIL_VERSION}.tar.gz" > /tmp/SHA256SUM \
  && sha256sum /tmp/gsutil_${GSUTIL_VERSION}.tar.gz \
  && ( cd /tmp; sha256sum -c SHA256SUM; ) \
  && tar -C /opt -zxf /tmp/gsutil_${GSUTIL_VERSION}.tar.gz \
  && ln -s /opt/gsutil/gsutil /usr/local/bin/gsutil \
  && rm -f /tmp/* \
  && find /opt ! -group 0 -exec chgrp -h 0 {} \; \
  ;

RUN set -x \
  && curl -o /tmp/gomplate_linux-amd64-slim -L https://github.com/hairyhenderson/gomplate/releases/download/${GOMPLATE_VERSION}/gomplate_linux-amd64-slim \
  && echo "${GOMPLATE_CHECKSUM}  gomplate_linux-amd64-slim" > /tmp/SHA256SUM \
  && sha256sum /tmp/gomplate_linux-amd64-slim \
  && ( cd /tmp; sha256sum -c SHA256SUM; ) \
  && mv /tmp/gomplate_linux-amd64-slim /usr/local/bin/gomplate \
  && chmod +x /usr/local/bin/gomplate \
  && rm -f /tmp/* \
  ;

COPY entry.sh /entry.sh
ENTRYPOINT ["/entry.sh"]
CMD ["/bin/sh"]
COPY boto.tmpl /.boto.tmpl

# Stop running as root
RUN set -x \
  && adduser -u 1000 -D gsutil \
  && adduser -u 1001 -D jenkins \
  ;
USER gsutil

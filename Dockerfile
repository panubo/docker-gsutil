FROM alpine:3.7

ENV GSUTIL_VERSION=4.28
ENV GSUTIL_CHECKSUM=1ebc2e01deb5c6511f4a82ca293a5979a9bc625ae52326660dde7b14cfec0dc2

ENV GOMPLATE_VERSION=v2.2.0
ENV GOMPLATE_CHECKSUM=0e09e7cd6fb5e96858255a27080570624f72910e66be5152b77a2fd21d438dd7

RUN set -x \
  && apk --no-cache add python bash curl ca-certificates tar make py-crcmod \
  ;

RUN set -x \
  && mkdir -p /opt \
  && curl -o /tmp/gsutil_${GSUTIL_VERSION}.tar.gz "https://storage.googleapis.com/pub/gsutil_${GSUTIL_VERSION}.tar.gz" \
  && echo "${GSUTIL_CHECKSUM}  gsutil_${GSUTIL_VERSION}.tar.gz" > /tmp/SHA256SUM \
  && ( cd /tmp; sha256sum -c SHA256SUM; ) \
  && tar -C /opt -zxf /tmp/gsutil_${GSUTIL_VERSION}.tar.gz \
  && ln -s /opt/gsutil/gsutil /usr/local/bin/gsutil \
  && rm -f /tmp/* \
  ;

RUN set -x \
  && curl -o /tmp/gomplate_linux-amd64-slim -L https://github.com/hairyhenderson/gomplate/releases/download/${GOMPLATE_VERSION}/gomplate_linux-amd64-slim \
  && echo "${GOMPLATE_CHECKSUM}  gomplate_linux-amd64-slim" > /tmp/SHA256SUM \
  && ( cd /tmp; sha256sum -c SHA256SUM; ) \
  && mv /tmp/gomplate_linux-amd64-slim /usr/local/bin/gomplate \
  && chmod +x /usr/local/bin/gomplate \
  && rm -f /tmp/* \
  ;

COPY entry.sh /entry.sh
ENTRYPOINT ["/entry.sh"]
CMD ["/bin/sh"]
COPY boto.tmpl /home/user/.boto.tmpl

# Stop running as root
RUN set -x \
  && adduser -u 1000 -D user \
  && chown -R user:user /home/user \
  ;
USER user


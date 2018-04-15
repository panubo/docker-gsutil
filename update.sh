#!/usr/bin/env bash
# Update image to use latest version of gsutil

# TODO (trnubo): Add updating of gomplate

set -e

command -v gsutil >/dev/null || { echo "Requires gsutil installed locally."; exit 1; }

latest="$(gsutil ls -L gs://pub/gsutil.tar.gz | grep "gsutil_version:" | awk '{print $2}')"

echo "Version: ${latest}"

if [[ ! -e "gsutil_${latest}.tar.gz" ]]; then
  gsutil cp gs://pub/gsutil_${latest}.tar.gz ./
fi

checksum="$(sha256sum gsutil_${latest}.tar.gz | awk '{print $1}')"

echo "Checksum: ${checksum}"

sed -i -E -e "s/GSUTIL_VERSION=[0-9\\.]*/GSUTIL_VERSION=${latest#v}/" -e "s/GSUTIL_CHECKSUM=[0-9a-f]*/GSUTIL_CHECKSUM=${checksum}/" Dockerfile

# Docker gsutil

[![license](https://img.shields.io/github/license/panubo/docker-gsutil.svg)]()
[![Status](https://img.shields.io/badge/status-experimental-orange.svg)]()

All credentials are baked into the `~/.boto` config file instead of left in the environment. Using environment variables credentials seems to be problematic specially with AWS.

## AWS Credentials

The following environment variables are expected for AWS

* `AWS_ACCESS_KEY_ID`
* `AWS_SECRET_ACCESS_KEY`
* `AWS_SESSION_TOKEN` (only when using temporary credentials)

## GCP Credentials

Using service account credentials:

```
docker run --rm -it \
 -v ${HOME}/Downloads/test-XXXX.json:/application_default_credentials.json \
 -e GOOGLE_APPLICATION_CREDENTIALS=/application_default_credentials.json \
 panubo/gsutil:latest
```

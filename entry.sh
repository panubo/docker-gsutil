#!/usr/bin/env bash

set -xe

gomplate < /home/user/.boto.tmpl > /home/user/.boto

unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SECURITY_TOKEN AWS_SESSION_TOKEN

exec "${@}"

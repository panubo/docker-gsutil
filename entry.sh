#!/usr/bin/env bash

set -xe

gomplate < /.boto.tmpl > $HOME/.boto
chmod 600 $HOME/.boto

unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SECURITY_TOKEN AWS_SESSION_TOKEN

exec "${@}"

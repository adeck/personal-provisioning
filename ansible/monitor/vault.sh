#!/usr/bin/env bash

set -x
CUR_ENV=devel
ansible-vault create --vault-id $CUR_ENV@prompt \
        nogit/vaults/$CUR_ENV-vault.yaml


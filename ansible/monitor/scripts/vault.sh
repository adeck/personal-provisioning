#!/usr/bin/env bash

set -x
ansible-vault edit --vault-id $CUR_ENV@prompt \
        nogit/vaults/$CUR_ENV-vault.yaml


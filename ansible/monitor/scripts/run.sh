#!/usr/bin/env bash

ansible-playbook -v \
    -i inventory.yaml \
    --vault-id $CUR_ENV@prompt \
    "$@"


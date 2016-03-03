#!/usr/bin/env bash

set -x -e

. resources/venv/bin/activate
mkdir templates 2>/dev/null
./resources/lib/build.py > templates/centos.json
packer build templates/centos.json



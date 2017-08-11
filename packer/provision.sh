#!/usr/bin/env bash

set -x

mkdir templates 2>/dev/null
mkdir resources/templates 2>/dev/null
./resources/lib/build.py > templates/debian.json
packer build templates/debian.json



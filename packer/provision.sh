#!/usr/bin/env bash

set -x -e

./resources/lib/build.py > templates/centos.json
packer build templates/centos.json



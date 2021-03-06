#!/usr/bin/env bash

set -x -e

mkdir() {
  local dir="$1"
  [ ! -d "$dir" ] || command mkdir "$dir"
}
mkdir templates
cd resources
mkdir venv
virtualenv venv
. venv/bin/activate
pip install --upgrade pip || true
pip install pyyaml


#!/usr/bin/env bash

set -x

pushd ../terraform-infra/real
  IP="$(./path.py infra)"
popd

echo "$IP" | python -c "
from jinja2 import Template
from sys import stdin

ip = stdin.read().strip()
for fname in ['inventory.ini', 'ssh_config']:
  with open('%s.j2' % fname, 'r') as f:
    content = f.read()
  templated = Template(content).render(gw_hostname=ip)
  with open(fname, 'w') as f:
    f.write(templated)
"

cp ~/.ssh/config ~/.ssh/config.bak$$ && cp ssh_config ~/.ssh/config
{
  ssh -oStrictHostKeyChecking=no gw exit
  ssh -oStrictHostKeyChecking=no salt-infra exit
  ssh -oStrictHostKeyChecking=no monitoring-infra exit
  ansible-playbook -i inventory.ini play.yml
}
cp ~/.ssh/config.bak$$ ~/.ssh/config


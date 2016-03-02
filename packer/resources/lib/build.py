#!/usr/bin/env python2

# NOTE: this was copied (slightly modified) from:
# http://stackoverflow.com/questions/528281/how-can-i-include-an-yaml-file-inside-another
#

# TODO -- give this a user-friendly TUI, upload to github
# NOTE -- this will never be a packer plugin, because they force plugins to use
#         golang, and I'm not enamored with that language.

templates = [
  'centos'
]

import yaml
import json
from os import path

class Loader(yaml.Loader):

    def __init__(self, stream):
        self._root = path.split(stream.name)[0]
        super(Loader, self).__init__(stream)

    def include(self, node):
        filename = path.join(self._root, self.construct_scalar(node))
        with open(filename, 'r') as f:
            return yaml.load(f, Loader)

Loader.add_constructor('!include', Loader.include)

if __name__ == '__main__':
  for template in templates:
    with open(path.join('resources', 'templates', template, 'main.yaml'), 'r') as f:
      data = yaml.load(f, Loader)
    print json.dumps(data, sort_keys=True, indent=2)


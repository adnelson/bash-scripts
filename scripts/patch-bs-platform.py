#!/usr/bin/env python3
import json, os

print("Adding postinstall to patch ocaml binaries")

pkg_j = json.load(open('package.json'))
postinstall = pkg_j['scripts'].get('postinstall', '')
patch_cmd = os.path.expanduser('~/.bash-scripts/scripts/patch-ocaml-binaries.sh')
if not postinstall:
   postinstall = patch_cmd
elif patch_cmd not in postinstall:
   postinstall = patch_cmd + ' && ' + postinstall
pkg_j['scripts']['postinstall'] = postinstall
open('package.json', 'w').write(json.dumps(pkg_j, indent=2))

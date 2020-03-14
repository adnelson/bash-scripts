#!/usr/bin/env python3
import argparse
import json
from os.path import realpath, expanduser, isfile, join

def norm_package_json_path(p):
    if isfile(p):
        return p
    p_j = join(p, 'package.json')
    if isfile(p_j):
        return p_j
    raise OSError("No such file " + p + " or " + p_j)

def main(source, dest, ignore, noconfirm):
    with open(source) as source_f:
        with open(dest) as dest_f:
            source_pj = json.load(source_f)
            dest_pj = json.load(dest_f)

    source_scripts = source_pj['scripts']
    dest_scripts = dest_pj['scripts']
    keys_to_copy = [k for k in source_scripts if (not ignore or k not in ignore)]
    new_scripts = {k: source_scripts[k] for k in keys_to_copy if k not in dest_scripts}
    updated_scripts = {k: source_scripts[k]
                       for k in keys_to_copy
                       if k in dest_scripts and source_scripts[k] != dest_scripts[k]}
    new_dest_scripts = dict(dest_scripts, **updated_scripts, **new_scripts)

    if not new_scripts and not updated_scripts:
        print("No new or modified scripts")
        return
    print("Modified scripts:", list(updated_scripts.keys()))
    print("New scripts:", json.dumps(new_scripts, indent=2))
    if not noconfirm:
        input("Press enter to confirm, Ctrl-C to cancel...")

    dest_pj['scripts'] = new_dest_scripts

    with open(dest, 'w') as dest_f:
        dest_f.write(json.dumps(dest_pj, indent=2))


parser = argparse.ArgumentParser()
parser.add_argument('-s', '--source', type=norm_package_json_path, required=True)
parser.add_argument('-d', '--dest', type=norm_package_json_path, required=True)
parser.add_argument('-i', '--ignore', nargs='*', default=[])
parser.add_argument('-y', '--noconfirm', action='store_true', default=False)
args = parser.parse_args()
main(**vars(args))
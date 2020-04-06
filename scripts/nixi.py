#!/usr/bin/env python3
'''User package management script for nix'''
from getpass import getuser
from os.path import dirname, join, exists, realpath, expanduser
import argparse
import json
import subprocess as sp
import sys

def existing_path(path):
    '''Check that a path exists'''
    if path.startswith('<') and path.endswith('>'):
        # TODO could validate that path is in NIX_PATH
        return path
    full_path = realpath(expanduser(path))
    if not exists(full_path):
        raise ValueError("No such path: {}".format(path))
    return full_path

def get_directory():
    '''Get the root directory of nix and JSON files'''
    return realpath(join(dirname(dirname(__file__)), 'nix'))

def is_in_nixpkgs(name, nixpkgs=None):
    '''Check if a package appears in nixpkgs'''
    nixpkgs = nixpkgs or '<nixpkgs>'
    expr = "with import %s {}; lib.isDerivation pkgs.%s" % (nixpkgs, name)
    try:
        is_deriv = sp.check_output(['nix-instantiate', '--eval', '--expr', expr])
        return is_deriv.decode().strip() == 'true'
    except sp.CalledProcessError as err:
        return False

def nix_install(path, attr=None):
    '''Install from a path to a nix file, optionally a particular attribute within that path.'''

def update_packages_json(path, name, uninstall):
    """Add a path to the packages json file."""
    with open(path) as f:
        j = json.load(f)
    if uninstall:
        if name not in j:
            print("Package", name, "wasn't in", path)
            return False
        else:
            print("Removing package", name, "from", path)
            j = [p for p in j if p != name]
    else:
        if name not in j:
            print("New package", name, "in", path)
            j.append(name)
        else:
            print("Package", name, "was already in", path)
            return False

    with open(path, "w") as f:
        f.write(json.dumps(list(sorted(j)), indent=2))
    return True


def main(directory, name, nixpkgs, uninstall, shared):
    user_packages = join(directory, 'userPackages.nix')
    user = 'root' if getuser() == 'root' else 'allen'
    attr = user + '.' + sys.platform

    if name:
        if not is_in_nixpkgs(name, nixpkgs=nixpkgs):
            raise RuntimeError("No such package {}".format(name))
        jsonpath = join(directory, (attr if not shared else user + '.' + 'shared') + '.json')
        should_install = update_packages_json(jsonpath, name, uninstall=uninstall)
        if not should_install:
            return
    elif uninstall:
        sp.check_call(['nix-env', '-e', '-'.join([user, 'user', 'packages'])])
        print("Uninstalled everything")
        return

    sp.check_call(['nix-env', '-f', join(directory, 'userPackages.nix'), '-i', '-A', attr])

    if sys.platform == 'linux':
        sp.check_call(['rm', '-f', '~/.cache/dmenu_run'])

    print('OK!')

def get_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('name', nargs='?', default=None,
                        help="name of package to add/remove. If not specifies, installs "
                        "current packages.")
    parser.add_argument('--nixpkgs', type=existing_path, default='<nixpkgs>',
                        help="path expression for nixpkgs, defaults to <nixpkgs>")
    parser.add_argument('--directory', type=existing_path,
                        help="directory where userPackages.nix and json package lists are stored.")
    parser.add_argument('-U', '--uninstall', action="store_true", default=False,
                        help="uninstall mode: remove package if it is installed")
    parser.add_argument('--shared', action="store_true", default=False,
                        help="add/remove from shared packages instead of platform-specific")
    args = parser.parse_args()
    if args.directory is None:
        args.directory = get_directory()
    return args

if __name__ == "__main__":
    args = get_args()
    main(**vars(args))

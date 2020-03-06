#!/usr/bin/env python3
import argparse
import subprocess as sp
import os

uid = int(sp.check_output(["id", "-u"]).decode().strip())
if uid != 0:
    exit("This must be run as root (got {})".format(uid))

parser = argparse.ArgumentParser()
parser.add_argument("-n", "--no-update-channel",
                    action="store_false", dest="update_channel",
                    help="Don't update nixos channel first")
parser.add_argument("-m", "--message", help="Commit message")
parser.add_argument("-t", "--test-only", action="store_true", help="Test only (don't run `switch`)")
parser.set_defaults(update_channel=True)
args = parser.parse_args()

os.chdir("/etc/nixos")
if sp.call(["git", "diff-index", "--quiet", "HEAD", "--"]):
    if not args.message:
        exit("Changes exist but no commit message was given. Use -m/--message")
    sp.check_call(["git", "add", "--all", "."])
    sp.check_call(["git", "commit", "-m", args.message])

if args.update_channel:
    sp.check_call(["nix-channel", "--update", "nixos"])
sp.check_call(["nixos-rebuild", "test"])
if not args.test_only:
    sp.check_call(["nixos-rebuild", "switch"])

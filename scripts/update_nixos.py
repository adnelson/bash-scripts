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
parser.add_argument("message", help="Commit message")
parser.add_argument("-s", "--switch", action="store_true", default=False)
parser.set_defaults(update_channel=True)
args = parser.parse_args()

os.chdir("/etc/nixos")
if sp.call(["git", "diff-index", "--quiet", "HEAD", "--"]):
    if not args.message:
        exit("Changes exist but no commit message was given. Use -m/--message")
    sp.check_call(["git", "add", "--all", "."])
    sp.check_call(["git", "commit", "-m", args.message])
else:
    last_commit_message = sp.check_output(["git", "log", "-n1", "--format=%B"])
    last_commit_message = last_commit_message.decode().strip()
    if args.message and args.message != last_commit_message:
        exit("No changes to configuration.nix exist, but a commit message "
             "was passed in which is different than the most recent commit.\n\n"
             "The most recent commit message was: " + repr(last_commit_message))

if args.update_channel:
    sp.check_call(["nix-channel", "--update", "nixos"])
sp.check_call(["nixos-rebuild", "test"])
if args.switch:
    sp.check_call(["nixos-rebuild", "switch"])
else:
    print("Test build succeeded. Rerun with -s/--switch to actually "
          "switch to the new configuration")

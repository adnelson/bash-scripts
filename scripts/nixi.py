from os.path import dirname, join, exists
import argparse
import subprocess as sp
import json
import getpass

parser = argparse.ArgumentParser()
parser.add_argument("package")
parser.add_argument("--user", default=getpass.getuser())
parser.add_argument("--python", action="store_true", default=False)
args = parser.parse_args()

json_path = join(dirname(dirname(__file__)), "nix", args.user + ".json")
if not exists(json_path):
    config = {
        "toplevel": [],
        "python3Packages": []
    }
else:
    with open(json_path) as f:
        config = json.load(f)

current = config["python3Packages" if args.python else "toplevel"]

if args.package in current:
    print(args.package, "is already installed")
    exit()

with open(json_path, "w") as f:
    f.write(json.dumps(, indent=2, sort_keys=True))

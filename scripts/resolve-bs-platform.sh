#!/usr/bin/env bash
# Add a `resolution` to the package.json to make sure
# that it grabs the right bs-platform
set -eo pipefail

if [[ ! -e package.json ]]; then
  echo 'No package.json in the current directory' >&2
  exit 1
fi

set -x

bs_platform_dir=$(nix-build ~/nixpkgs -A bs-platform)

if [[ ! -e $bs_platform_dir ]] || [[ ! -e $bs_platform_dir/package.json ]]; then
  echo "ERROR: Couldn't find a package.json in $bs_platform_dir" >&2
  exit 1
fi

echo "Setting resolution of bs-platform to $bs_platform_dir"

python3 <<EOF
import json
pkg_j = json.load(open('package.json'))
resolutions = pkg_j.setdefault('resolutions', {})
resolutions['bs-platform'] = "$bs_platform_dir"
open('package.json', 'w').write(json.dumps(pkg_j, indent=2))
EOF

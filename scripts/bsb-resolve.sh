#!/usr/bin/env bash
set -eo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

bs_platform_dir=$($DIR/build-bs-platform.sh)

if [[ ! -e $bs_platform_dir ]] || [[ ! -e $bs_platform_dir/package.json ]]; then
  echo "ERROR: Couldn't find a package.json in $bs_platform_dir" >&2
  exit 1
fi

echo "Setting version of bs-platform to $bs_platform_dir"

python3 <<EOF
import json
pkg_j = json.load(open('package.json'))
if 'bs-platform' in pkg_j['dependencies']:
    pkg_j['dependencies']['bs-platform'] = "file://$bs_platform_dir"
elif 'bs-platform' in pkg_j['devDependencies']:
    pkg_j['devDependencies']['bs-platform'] = "file://$bs_platform_dir"

# resolutions = pkg_j.setdefault('resolutions', {})
# resolutions['bs-platform'] = "$bs_platform_dir"

open('package.json', 'w').write(json.dumps(pkg_j, indent=2))
EOF

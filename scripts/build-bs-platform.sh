#!/usr/bin/env bash

bs_platform_dir=$(nix-build --no-out-link ~/nixpkgs -A bs-platform)

if [[ ! -e $bs_platform_dir ]] || [[ ! -e $bs_platform_dir/package.json ]]; then
  echo "ERROR: Couldn't find a package.json in $bs_platform_dir" >&2
  exit 1
fi

echo $bs_platform_dir

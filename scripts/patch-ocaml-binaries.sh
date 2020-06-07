#!/usr/bin/env bash
set -e

if ! [ -e package.json ]; then
  echo "No package.json in $PWD" >&2
  exit 1
fi

set -x

interpreter=$(nix-build '<nixpkgs>' --no-out-link -A glibc)/lib/ld-linux-x86-64.so.2

echo "Setting interpreter: $interpreter"

function patch_file () {
  local path="$1"
  local strict="${2:-$STRICT_MODE}"
  if [ ! -e $path ]; then
    if [ -n $strict ]; then
      echo "$path doesn't exist" >&2
    fi
    exit 1
  else
    patchelf --set-interpreter $interpreter "$path"
  fi
}


if [ -e node_modules/@ahrefs/bs-emotion-ppx ]; then
  (
    cd node_modules/@ahrefs/bs-emotion-ppx
    if [[ -e ./ppx ]]; then
      patch_file ./ppx strict
      patch_file ./ppx.exe strict
      patch_file ./exe/bs-emotion-ppx-linux-x64.exe strict
    else
      patch_file ./bin/bs-emotion-ppx strict
      patch_file ./3/i/ahrefs__s__bs_emotion_ppx-c71cd397/bin/bs-emotion-ppx strict
    fi
  )
fi

patch_file ./node_modules/get_in_ppx/ppx
patch_file ./node_modules/gentype/gentype.exe
patch_file ./node_modules/@dylanirlbeck/tailwind-ppx/tailwind-ppx

echo "Finished patching!"

yarn re:clean

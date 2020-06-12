#!/bin/sh
# Runs lint-staged for every package.json

if type -p fd &>/dev/null; then
  cmd="fd package.json --type f"
else
  cmd="find . -maxdepth 2 -name package.json -type f"
fi

for f in $($cmd); do
  # Check if there's a lint-staged key in the package.json; if so run it
  if cat $f | jq -e '."lint-staged"' >/dev/null; then
    (
      cd $(dirname $f)
      echo "Linting $(pwd)"
      npx lint-staged
    )
  fi
done

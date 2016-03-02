# This needs to be run as sudo, which is why it's a separate file
# rather than just an inlined function in the `nix` directory.
DEFAULT_MSG=
msg="${1:-"latest update $(date)"}"
(
  cd /etc/nixos >/dev/null
  git add --all .
  git commit -m "$msg"
)
nixos-rebuild test && nixos-rebuild switch

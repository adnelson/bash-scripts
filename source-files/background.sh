if [[ -z $IN_NIX_SHELL ]]; then

BACKGROUND_IMAGES=$HOME/.background-images


if ! env | grep -q SSH_CLIENT; then
  if which feh >/dev/null 2>&1 && [[ -e $BACKGROUND_IMAGES/random_background ]]; then
    $BACKGROUND_IMAGES/random_background
  fi
fi


fi # if in nix shell

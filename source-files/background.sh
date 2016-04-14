if ! env | grep -q SSH_CLIENT; then
  if which feh >/dev/null 2>&1 && [[ -e ~/Desktop/background-images/random_background ]]; then
    ~/Desktop/background-images/random_background
  fi
fi

if [[ -e /opt/homebrew/bin/brew ]]; then
  echo "Setting up homebrew"
  eval "$(/opt/homebrew/bin/brew shellenv $CURRENT_SHELL)"
fi


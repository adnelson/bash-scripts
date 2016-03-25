# ipython > python
alias ipy='ipython'

# because it's a common misspelling
alias pyton='python'

# python work folder
alias py='cd ~/workspace/python'

# Start/activate a virtualenv
alias venv='virtualenv venv; source venv/bin/activate'

# grumble grumble
export PYTHONPATH=$PYTHONPATH:/lib/python2.7/site-packages
export PYTHONPATH=$PYTHONPATH:/usr/lib/python2.7/site-packages

if [[ -n $ENABLE_PYENV ]]; then
  echo "Activating pyenv..."
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
fi

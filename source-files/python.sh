# Hack because version management sux on osx...
if [[ -e /Library/Frameworks/Python.framework/Versions/3.6/bin ]]; then
  VIRTUALENV_BIN=/Library/Frameworks/Python.framework/Versions/3.6/bin/virtualenv
else
  VIRTUALENV_BIN=virtualenv
fi

# ipython > python
alias ipy='ipython'

# because it's a common misspelling
alias pyton='python'

# python work folder
alias py='cd ~/workspace/python'

# Start/activate a virtualenv
alias venv='$VIRTUALENV_BIN ~/.venvs/$(basename $PWD) && source ~/.venvs/$(basename $PWD)/bin/activate'

# Activates a python virtualenv, assuming the path below is appropriate.
alias act='if [ -e ~/.venvs/$(basename $PWD) ]; then source ~/.venvs/$(basename $PWD)/bin/activate; else venv; fi'

unset PYTHONPATH
# grumble grumble
# export PYTHONPATH=$PYTHONPATH:/lib/python2.7/site-packages
# export PYTHONPATH=$PYTHONPATH:/usr/lib/python2.7/site-packages

if [[ -n $ENABLE_PYENV ]]; then
  echo "Activating pyenv..."
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
fi

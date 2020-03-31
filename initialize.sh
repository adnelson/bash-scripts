#!/usr/bin/env bash

export SH_CONFIG=$(cd $(dirname $0); echo $PWD)
(cd $SH_CONFIG && git submodule update --init)
if [[ -d ~/.secrets ]]; then
  ln -sfv ~/.secrets $SH_CONFIG/secrets
fi
ln -sfv $SH_CONFIG/oh-my-zsh $HOME/.oh-my-zsh
ln -sfv $SH_CONFIG/shrc.sh $HOME/.zshrc
ln -sfv $SH_CONFIG/shrc.sh $HOME/.bashrc
rm -f $SH_CONFIG/oh-my-zsh/oh-my-zsh
if [[ -d ~/.xmonad ]]; then
  ln -sfv $SH_CONFIG/xmonad/xmonad.hs ~/.xmonad
fi

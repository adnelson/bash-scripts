#!/usr/bin/env bash

export ZSH_CONFIG=$(cd $(dirname $0); echo $PWD)
(cd $ZSH_CONFIG && git submodule update --init)
(cd $ZSH_CONFIG && chmod 0600 secrets/id_adnelson)
ln -sfv $ZSH_CONFIG/oh-my-zsh $HOME/.oh-my-zsh
ln -sfv $ZSH_CONFIG/zshrc.sh $HOME/.zshrc
rm -f $ZSH_CONFIG/oh-my-zsh/oh-my-zsh

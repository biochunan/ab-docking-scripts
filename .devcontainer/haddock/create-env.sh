#!/bin/zsh

# init conda
conda init zsh

# source .zshrc to activate conda
source $HOME/.zshrc

# turn off conda auto-activate base
conda config --set auto_activate_base false

# create env
envname="haddock"
conda create -n $envname python=3.10 -y && conda activate $envname

# install dependencies
END
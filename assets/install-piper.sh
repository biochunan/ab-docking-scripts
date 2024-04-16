#!/bin/zsh

# Aim: install piper

# init conda
source $HOME/.zshrc
conda init zsh > /dev/null 2>&1
conda activate piper-py27

# config
BASE=$(dirname $(realpath $0))  # => assets

# install pdb2pqr
pushd $BASE
mkdir -p ./docking-tools/
tar -zxf piper.tar.gz -C ./docking-tools
pushd ./docking-tools/piper/protein_prep/pdb2pqr-1.9.0
python ./scons/scons.py install
popd  # => assets
sudo ln -s $PWD/docking-tools/piper/piper /usr/local/bin/piper

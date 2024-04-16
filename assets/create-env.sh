#!/bin/zsh

# Aim: create conda env

# init conda
source $HOME/.zshrc > /dev/null 2>&1
conda init zsh

# install abagdocking
conda create -n abagdocking python=3.10 -y
conda activate abagdocking
conda install conda-forge::gcc -y
conda install conda-forge::gcc_linux-64 -y
conda install conda-forge::gxx_linux-64 -y
cd /home/vscode/docking
pip install -e .

# create piper env
conda create -n piper-py27 python=2.7 -y

# cleanup
conda deactivate
conda clean --all -y
pip cache purge

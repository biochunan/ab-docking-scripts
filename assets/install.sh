#!/bin/zsh

# Aim: install bioplib and bioptools

BASE=$(dirname $(realpath $0))  # /path/to/.devconatiner/assets

# decompress
pushd $BASE
tar -zxf bioptools-V1.10.tar.gz
tar -zxf bioplib-V3.11.tar.gz
tar -zxf megadock-4.1.1.tar.gz
tar -zxf fftw-3.3.10.tar.gz
tar -zxf zrank_linux_64bit.tar.gz  # => zrank_linux_64bit
tar -zxf DockQ.tar.gz  # => DockQ
popd

# ------------------------------------------------------------------------------
# bioplib
# ------------------------------------------------------------------------------
# dependencies
sudo apt update && sudo apt install libxml2 libxml2-dev -y

pushd $BASE/bioplib-3.11/src
# change installation directory
sed -i 's|DEST=${HOME}|DEST=/opt/bioplib|g' Makefile
make
sudo make install
sudo make installdata
echo "export DATADIR=$HOME/data >> ~/.zshrc"
popd


# ------------------------------------------------------------------------------
# bioptools
# ------------------------------------------------------------------------------
pushd $BASE/bioptools-1.10/src
./makemake.pl -install=/opt/bioptools \
    -libdir=/opt/bioplib/lib \
    -incdir=/opt/bioplib/include \
    -bindir=/usr/local/bin \
    -datadir=/opt/bioptools/data
make
sudo make install
popd


# ------------------------------------------------------------------------------
# fftw
# ------------------------------------------------------------------------------
pushd $BASE/fftw-3.3.10
./configure --enable-float --enable-sse2 --prefix=/opt/fftw
make
sudo make install
popd


# ------------------------------------------------------------------------------
# megadock-gpu
# ------------------------------------------------------------------------------
# install cuda-samples
pushd /opt
sudo curl -o cuda-samples-12.4.tar.gz -L https://github.com/NVIDIA/cuda-samples/archive/refs/tags/v12.4.tar.gz
sudo tar -xf cuda-samples-12.4.tar.gz  # => cuda-samples-12.4
sudo rm cuda-samples-12.4.tar.gz
popd

# modify installation files
pushd $BASE/megadock-4.1.1
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-12/lib64/
export PATH=$PATH:/usr/local/cuda-12/bin
# modify Makefile
sed -i 's|CUDA_INSTALL_PATH ?= /opt/cuda/6.0|CUDA_INSTALL_PATH ?= /usr/local/cuda-12|g' Makefile
sed -i 's|CUDA_SAMPLES_PATH ?= /opt/cuda/6.0/samples|CUDA_SAMPLES_PATH ?= /opt/cuda-samples-12.4|g' Makefile
sed -i 's|FFTW_INSTALL_PATH ?= /work0/t2gmegadock/share/fftw|FFTW_INSTALL_PATH ?= /opt/fftw|g' Makefile
sed -i 's|CPPCOMPILER       ?= icpc|CPPCOMPILER       ?= g++|g' Makefile
sed -i 's|MPICOMPILER       ?= mpicxx|#MPICOMPILER       ?= mpicxx|g' Makefile
sed -i 's|OMPFLAG           ?= -openmp|OMPFLAG           ?= -fopenmp|g' Makefile
sed -i 's|USE_MPI    := 1|USE_MPI    := 0|g' Makefile
# correct cuda_helper.h path
# replace line 102 with '	INCLUDES += -I$(CUDA_INSTALL_PATH)/include -I$(COMMONDIR)/inc -I$(CUDA_SAMPLES_PATH)/Common'
sed -i '102s|.*|	INCLUDES += -I$(CUDA_INSTALL_PATH)/include -I$(COMMONDIR)/inc -I$(CUDA_SAMPLES_PATH)/Common|' Makefile
popd

# install under /opt
sudo cp -r megadock-4.1.1 /opt/megadock-4.1.1
pushd /opt/megadock-4.1.1
# This crates an executable `megadock-gpu`
sudo make
popd

# install megadock cpu version
pushd /opt/megadock-4.1.1
# This creates an executable `megadock`
sed -i 's|USE_GPU    := 1|USE_GPU    := 0|g' Makefile
sudo make
popd

# add to PATH
sudo ln -s /opt/megadock-4.1.1/megadock     /usr/local/bin/megadock
sudo ln -s /opt/megadock-4.1.1/megadock-gpu /usr/local/bin/megadock-gpu
sudo ln -s /opt/megadock-4.1.1/decoygen     /usr/local/bin/decoygen

# ------------------------------------------------------------------------------
# zrank
# ------------------------------------------------------------------------------
sudo cp zrank_linux_64bit/zrank /usr/local/bin/zrank


# ------------------------------------------------------------------------------
# DockQ
# ------------------------------------------------------------------------------
pushd $BASE/DockQ
pip install .
popd

# ------------------------------------------------------------------------------
# cleanup
# ------------------------------------------------------------------------------
rm -rf bioptools-1.10
rm -rf bioplib-3.11
rm -rf fftw-3.3.10
rm -rf megadock-4.1.1
rm -rf zrank_linux_64bit
#!/usr/bin/env bash

ROOT=$HOME/scidac

mkdir -p ${ROOT}
pushd ${ROOT}

git clone https://github.com/usqcd-software/qmp.git
pushd qmp
# git checkout master
git checkout 3010fef5b
popd

git clone https://github.com/usqcd-software/qdpxx.git --recursive
pushd qdpxx
# git checkout devel
git checkout 7a4bd2c2f
git submodule update --recursive
popd

git clone https://github.com/JeffersonLab/qdp-jit.git --recursive
pushd qdp-jit
# git checkout devel
git checkout 7ffb650ec
git submodule update --recursive
popd

git clone https://github.com/JeffersonLab/chroma.git --recursive
pushd chroma
git checkout chroma-devel-2024-02-26
git submodule update --recursive
popd

git clone https://github.com/lattice/quda.git
pushd quda
# git checkout develop
git checkout b930e9379
popd

wget https://github.com/cpm-cmake/CPM.cmake/releases/download/v0.38.5/CPM.cmake -O CPM_0.38.5.cmake
wget https://gitlab.com/libeigen/eigen/-/archive/3.4.0/eigen-3.4.0.tar.bz2

popd

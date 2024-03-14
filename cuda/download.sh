#!/usr/bin/env bash

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

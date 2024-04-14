#!/usr/bin/env bash

DIR=$( cd $( dirname ${BASH_SOURCE[0]} ) && pwd )
ROOT=${DIR}/scidac

mkdir -p ${ROOT}
pushd ${ROOT}

git clone https://code.ihep.ac.cn/ihep-lqcd/qmp.git
pushd qmp
git checkout master
popd

git clone https://code.ihep.ac.cn/ihep-lqcd/qdpxx.git --recursive
pushd qdpxx
git checkout devel-ihep
git submodule update --recursive
popd

git clone https://code.ihep.ac.cn/ihep-lqcd/qdp-jit.git --recursive
pushd qdp-jit
git checkout hotfix/dtk-23.10
git submodule update --recursive
popd

git clone https://code.ihep.ac.cn/ihep-lqcd/chroma.git --recursive
pushd chroma
git checkout chroma-devel-2024-02-26
git submodule update --recursive
popd

git clone https://code.ihep.ac.cn/ihep-lqcd/quda.git
pushd quda
git checkout hotfix/dtk-23.10
popd

wget https://github.com/cpm-cmake/CPM.cmake/releases/download/v0.38.5/CPM.cmake -O CPM_0.38.5.cmake
wget https://gitlab.com/libeigen/eigen/-/archive/3.4.0/eigen-3.4.0.tar.bz2

popd

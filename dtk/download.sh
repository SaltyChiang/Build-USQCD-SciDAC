#!/usr/bin/env bash

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
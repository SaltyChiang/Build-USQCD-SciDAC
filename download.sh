#!/usr/bin/env bash

TARGET=$1
if [ -z $TARGET ]; then
    echo "Error: Lack of parameters"
    echo "Usage: download.sh TARGET"
    exit 1
fi

DIR=$( cd $( dirname ${BASH_SOURCE[0]} ) && pwd )
SCIDAC=${DIR}/scidac

mkdir -p ${SCIDAC}
pushd ${SCIDAC}

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
git checkout 299b7937e
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
wget https://gitlab.com/libeigen/eigen/-/archive/3.4.0/eigen-3.4.0.tar.bz2 -O eigen-3.4.0.tar.bz2

popd

pushd ${DIR}

source ${TARGET}/patch.sh
cp ${TARGET}/build* ${SCIDAC}
tar -czf scidac.tgz scidac

popd

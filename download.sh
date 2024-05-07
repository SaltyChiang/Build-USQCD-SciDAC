#!/usr/bin/env bash

TARGET=$1
if [ -z $TARGET ]; then
    echo "Error: Lack of parameters TARGET (could be \"cuda\" or \"dtk\")"
    echo "Usage: download.sh TARGET"
    exit 1
fi

DIR=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
SCIDAC=${DIR}/scidac

mkdir -p ${SCIDAC}
pushd ${SCIDAC}

git clone https://github.com/usqcd-software/qmp.git
pushd qmp
git checkout master
git pull
git checkout 3010fef5b
popd

git clone https://github.com/usqcd-software/qdpxx.git --recursive
pushd qdpxx
git checkout devel
git pull
git checkout 7a4bd2c2f
git submodule update --recursive
popd

git clone https://github.com/JeffersonLab/chroma.git --recursive
pushd chroma
git checkout devel
git pull
git checkout chroma-devel-2024-02-26
git submodule update --recursive
popd

if !([ ${TARGET} == "cpu" ]); then
    git clone https://github.com/JeffersonLab/qdp-jit.git --recursive
    pushd qdp-jit
    git checkout devel
    git pull
    git checkout 7c0cdf308
    git submodule update --recursive
    popd

    git clone https://github.com/lattice/quda.git
    pushd quda
    git checkout develop
    git pull
    git checkout c051eac9b
    popd

    if !([ -f CPM_0.38.5.cmake ] && [ "$(sha256sum CPM_0.38.5.cmake | awk '{print $1}')" == "192aa0ccdc57dfe75bd9e4b176bf7fb5692fd2b3e3f7b09c74856fc39572b31c" ]); then
        wget https://github.com/cpm-cmake/CPM.cmake/releases/download/v0.38.5/CPM.cmake -O CPM_0.38.5.cmake
    fi
    if !([ -f eigen-3.4.0.tar.bz2 ] && [ "$(sha256sum eigen-3.4.0.tar.bz2 | awk '{print $1}')" == "b4c198460eba6f28d34894e3a5710998818515104d6e74e5cc331ce31e46e626" ]); then
        wget https://gitlab.com/libeigen/eigen/-/archive/3.4.0/eigen-3.4.0.tar.bz2 -O eigen-3.4.0.tar.bz2
    fi
fi

popd

pushd ${DIR}

source ${TARGET}/patch.sh
cp ${TARGET}/build* ${SCIDAC}
tar -czf scidac.tgz scidac

popd

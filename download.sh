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
git reset
git checkout .
git checkout master
git pull
git checkout 3010fef5b
popd

git clone https://github.com/usqcd-software/qdpxx.git --recursive
pushd qdpxx
git reset
git checkout .
git checkout devel
git pull
git checkout 2e2f1175f
git submodule update --recursive
popd

git clone https://github.com/JeffersonLab/chroma.git --recursive
pushd chroma
git reset
git checkout .
git checkout devel
git pull
git checkout 59e7dc055
git submodule update --recursive
popd

git clone https://github.com/milc-qcd/milc_qcd.git
pushd milc_qcd
git reset
git checkout .
git checkout devel
git pull
git checkout 50cdbd0a8
popd

if !([ ${TARGET} == "openmp" ]); then
    git clone https://github.com/JeffersonLab/qdp-jit.git --recursive
    pushd qdp-jit
    git reset
    git checkout .
    git checkout devel
    git pull
    git checkout 623ac6ad8
    git submodule update --recursive
    popd

    git clone https://github.com/lattice/quda.git
    pushd quda
    git reset
    git checkout .
    git checkout develop
    git pull
    git checkout 08c6c016b
    popd

    if !([ -f CPM_0.40.2.cmake ] && [ "$(sha256sum CPM_0.40.2.cmake | awk '{print $1}')" == "c8cdc32c03816538ce22781ed72964dc864b2a34a310d3b7104812a5ca2d835d" ]); then
        wget https://github.com/cpm-cmake/CPM.cmake/releases/download/v0.40.2/CPM.cmake -O CPM_0.40.2.cmake
    fi
    if !([ -f e67c494cba7180066e73b9f6234d0b2129f1cdf5.tar.bz2 ] && [ "$(sha256sum e67c494cba7180066e73b9f6234d0b2129f1cdf5.tar.bz2 | awk '{print $1}')" == "98d244932291506b75c4ae7459af29b1112ea3d2f04660686a925d9ef6634583" ]); then
        wget https://gitlab.com/libeigen/eigen/-/archive/e67c494cba7180066e73b9f6234d0b2129f1cdf5.tar.bz2 -O e67c494cba7180066e73b9f6234d0b2129f1cdf5.tar.bz2
    fi
fi

popd

pushd ${DIR}

source ${TARGET}/patch.sh
cp ${TARGET}/build* ${SCIDAC}
# tar -czf scidac.tgz scidac

popd

#!/usr/bin/env bash

ROOT=$(cd $(dirname ${BASH_SOURCE[0]:-${(%):-%x}}) && pwd)
TARGET=${ROOT}/$1
SRC=${ROOT}/scidac
SCRIPT=${ROOT}/script
PATCH=${ROOT}/patch

if [ -z $TARGET ]; then
    echo "Error: Empty or invalid TARGET (could be \"cuda\" or \"dtk\")"
    echo "Usage: download.sh TARGET"
    exit 1
fi

source ${SCRIPT}/download_common.sh
cp ${SCRIPT}/build_common.sh ${SRC}/

git_checkout qmp \
    https://github.com/usqcd-software/qmp.git \
    master \
    3010fef5b5784b3e6eeec9fff38cb9954a28ad42

git_checkout qdpxx \
    https://github.com/usqcd-software/qdpxx.git \
    devel \
    c1e9b5209f89d232af064a60004f8ac7c9a5c734

git_checkout chroma \
    https://github.com/JeffersonLab/chroma.git \
    devel \
    71ed3c2debc963641999abe6d40bb2532ba4e249

git_checkout milc_qcd \
    https://github.com/milc-qcd/milc_qcd.git \
    develop \
    26cfab368a02ffb34c2945207c8ed1b17e247d36

if ! [ $1 == "openmp" ]; then
    git_checkout qdp-jit \
        https://github.com/JeffersonLab/qdp-jit.git \
        devel \
        f7469b1558811cb4905f670f996827de3c5c0b68

    git_checkout quda \
        https://github.com/lattice/quda.git \
        develop \
        d61517229eadceeaae7aff616359958da4ef35c7

    wget_sha256 CPM_0.40.2.cmake \
        https://github.com/cpm-cmake/CPM.cmake/releases/download/v0.40.2/CPM.cmake \
        c8cdc32c03816538ce22781ed72964dc864b2a34a310d3b7104812a5ca2d835d

    wget_sha256 e67c494cba7180066e73b9f6234d0b2129f1cdf5.tar.bz2 \
        https://gitlab.com/libeigen/eigen/-/archive/e67c494cba7180066e73b9f6234d0b2129f1cdf5.tar.bz2 \
        98d244932291506b75c4ae7459af29b1112ea3d2f04660686a925d9ef6634583
fi

source ${TARGET}/patch.sh
cp ${TARGET}/build.sh ${SRC}/

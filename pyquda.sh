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

git_checkout quda \
    https://github.com/lattice/quda.git \
    develop \
    7d579d290e8722537b10332249da3a6d82deb7c5

wget_sha256 CPM_0.40.2.cmake \
    https://github.com/cpm-cmake/CPM.cmake/releases/download/v0.40.2/CPM.cmake \
    c8cdc32c03816538ce22781ed72964dc864b2a34a310d3b7104812a5ca2d835d

wget_sha256 e67c494cba7180066e73b9f6234d0b2129f1cdf5.tar.bz2 \
    https://gitlab.com/libeigen/eigen/-/archive/e67c494cba7180066e73b9f6234d0b2129f1cdf5.tar.bz2 \
    98d244932291506b75c4ae7459af29b1112ea3d2f04660686a925d9ef6634583

source ${TARGET}/patch.sh
cp ${TARGET}/build.sh ${SRC}/

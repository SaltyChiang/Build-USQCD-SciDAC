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

git clone https://github.com/lattice/quda.git
pushd quda
git restore *
git checkout develop
git pull
git checkout b58f1ecb5
popd

if !([ -f CPM_0.40.2.cmake ] && [ "$(sha256sum CPM_0.40.2.cmake | awk '{print $1}')" == "c8cdc32c03816538ce22781ed72964dc864b2a34a310d3b7104812a5ca2d835d" ]); then
    wget https://github.com/cpm-cmake/CPM.cmake/releases/download/v0.40.2/CPM.cmake -O CPM_0.40.2.cmake
fi
if !([ -f e67c494cba7180066e73b9f6234d0b2129f1cdf5.tar.bz2 ] && [ "$(sha256sum e67c494cba7180066e73b9f6234d0b2129f1cdf5.tar.bz2 | awk '{print $1}')" == "98d244932291506b75c4ae7459af29b1112ea3d2f04660686a925d9ef6634583" ]); then
    wget https://gitlab.com/libeigen/eigen/-/archive/e67c494cba7180066e73b9f6234d0b2129f1cdf5.tar.bz2 -O e67c494cba7180066e73b9f6234d0b2129f1cdf5.tar.bz2
fi

popd

pushd ${DIR}

source ${TARGET}/patch.sh
cp ${TARGET}/build* ${SCIDAC}
# tar -czf scidac.tgz scidac

popd

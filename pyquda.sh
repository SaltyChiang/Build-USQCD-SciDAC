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
if !([ -f eigen-3.4.0.tar.bz2 ] && [ "$(sha256sum eigen-3.4.0.tar.bz2 | awk '{print $1}')" == "b4c198460eba6f28d34894e3a5710998818515104d6e74e5cc331ce31e46e626" ]); then
    wget https://gitlab.com/libeigen/eigen/-/archive/3.4.0/eigen-3.4.0.tar.bz2 -O eigen-3.4.0.tar.bz2
fi

popd

pushd ${DIR}

source ${TARGET}/patch.sh
cp ${TARGET}/build* ${SCIDAC}
# tar -czf scidac.tgz scidac

popd

#!/usr/bin/env bash

function wget_sha256() {
    _URL=$1
    _FILE=$2
    _SHA256=$3
    if !([ -f ${_FILE} ] && [ "$(sha256sum ${_FILE} | awk '{print $1}')" == "${_SHA256}" ]); then
        wget ${_URL} -O ${_FILE}
    fi
}

TARGET=$1
if [ -z $TARGET ]; then
    echo "Error: Lack of parameters TARGET (could be \"cuda\" or \"dtk\")"
    echo "Usage: download.sh TARGET"
    exit 1
fi

DIR=$(cd $(dirname ${BASH_SOURCE[0]:-${(%):-%x}}) && pwd)
SCIDAC=${DIR}/scidac

mkdir -p ${SCIDAC}
pushd ${SCIDAC}

git clone https://github.com/lattice/quda.git
pushd quda
git reset
git checkout .
git checkout develop
git pull
git checkout bdad35828
popd

wget_sha256 \
    https://github.com/cpm-cmake/CPM.cmake/releases/download/v0.40.2/CPM.cmake \
    CPM_0.40.2.cmake \
    c8cdc32c03816538ce22781ed72964dc864b2a34a310d3b7104812a5ca2d835d
wget_sha256 \
    https://gitlab.com/libeigen/eigen/-/archive/e67c494cba7180066e73b9f6234d0b2129f1cdf5.tar.bz2 \
    e67c494cba7180066e73b9f6234d0b2129f1cdf5.tar.bz2 \
    98d244932291506b75c4ae7459af29b1112ea3d2f04660686a925d9ef6634583

popd

pushd ${DIR}

source ${TARGET}/patch.sh
cp common.sh ${TARGET}/build.sh ${SCIDAC}
# tar -czf scidac.tgz scidac

popd

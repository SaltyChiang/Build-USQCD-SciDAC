#!/usr/bin/env bash

if [ -d ${SCIDAC}/quda ]; then
    pushd ${SCIDAC}/quda
    git reset
    git checkout .
    git apply ${DIR}/patch/quda_cmake.patch
    popd
fi

#!/usr/bin/env bash

if [ -d ${SCIDAC}/qdp-jit ]; then
    pushd ${SCIDAC}/qdp-jit
    git reset
    git checkout .
    git apply ${DIR}/patch/qdp-jit_dtk.patch
    popd
fi

if [ -d ${SCIDAC}/quda ]; then
    pushd ${SCIDAC}/quda
    git reset
    git checkout .
    git apply ${DIR}/patch/quda_cmake.patch
    git apply ${DIR}/patch/quda_dtk.patch
    git apply ${DIR}/patch/quda_devtoolset-7.patch
    popd
fi

#!/usr/bin/env bash

if [ -d ${SCIDAC}/qdp-jit ]; then
    pushd ${SCIDAC}/qdp-jit
    git restore *
    git apply ${DIR}/patch/qdp-jit_dtk-23.10.patch
    popd
fi

if [ -d ${SCIDAC}/quda ]; then
    pushd ${SCIDAC}/quda
    git restore *
    git apply ${DIR}/patch/quda_offline.patch
    git apply ${DIR}/patch/quda_dtk-23.10.patch
    popd
fi

#!/usr/bin/env bash

if [ -d ${SCIDAC}/qdp-jit ]; then
    pushd ${SCIDAC}/qdp-jit
    git restore *
    git apply ${DIR}/patch/qdp-jit_dtk.patch
    popd
fi

if [ -d ${SCIDAC}/quda ]; then
    pushd ${SCIDAC}/quda
    git restore *
    git apply ${DIR}/patch/quda_dtk.patch
    git apply ${DIR}/patch/quda_dtk_performance.patch
    popd
fi

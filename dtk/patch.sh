#!/usr/bin/env bash

pushd ${SCIDAC}/qdp-jit
git restore *
git apply ${DIR}/patch/qdp-jit_dtk-23.10.patch
popd

pushd ${SCIDAC}/quda
git restore *
git apply ${DIR}/patch/quda_dtk-23.10.patch
popd

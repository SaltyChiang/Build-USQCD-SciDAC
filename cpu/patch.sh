#!/usr/bin/env bash

if [ -d ${SCIDAC}/qdp-jit ]; then
    pushd ${SCIDAC}/qdp-jit
    git reset
    git checkout .
    git apply ${DIR}/patch/qdp-jit_debian.patch
    popd
fi

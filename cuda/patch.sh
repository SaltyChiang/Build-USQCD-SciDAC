#!/usr/bin/env bash

if [ -d ${SCIDAC}/quda ]; then
    pushd ${SCIDAC}/quda
    git restore *
    git apply ${DIR}/patch/quda_offline.patch
    popd
fi

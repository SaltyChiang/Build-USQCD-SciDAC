#!/usr/bin/env bash

pushd ${SCIDAC}/quda
git restore *
git apply ${DIR}/patch/quda_offline.patch
popd

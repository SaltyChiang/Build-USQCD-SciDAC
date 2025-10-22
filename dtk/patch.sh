#!/usr/bin/env bash

git_apply qdp-jit \
    ${PATCH}/qdp-jit_dtk.patch

git_apply quda \
    ${PATCH}/quda_cmake.patch \
    ${PATCH}/quda_dtk.patch \
    ${PATCH}/quda_devtoolset-7.patch

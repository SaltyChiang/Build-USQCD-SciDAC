#!/usr/bin/env bash

BUILD_SHAREDLIB=ON
GPU_TARGET=gfx906
HETEROGENEOUS_ATOMIC=OFF
LLVM_VERSION=15
JOBS=16
QUDA_JOBS=16
OFFLINE=1

ROOT=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
SRC=${ROOT}
BIN=${ROOT}/build
DST=${ROOT}/install

# 0: Nothing; 1: Build and install; 2: Configure, build and install; 3: Clean, configure, build and install.
BUILD_PYQUDA=2

function build_quda() {
    if [ $1 -gt 0 ]; then
        mkdir -p ${BIN}/$3
        pushd ${BIN}/$3
        if [ $1 -gt 1 ]; then
            rm -rf CMakeCache.txt
            if [ $1 -gt 2 ]; then
                rm -rf ./*
            fi
            if [ ${OFFLINE} -gt 0 ]; then
                if !([ -f cmake/CPM_0.38.5.cmake ] && [ "$(sha256sum cmake/CPM_0.38.5.cmake | awk '{print $1}')" == "192aa0ccdc57dfe75bd9e4b176bf7fb5692fd2b3e3f7b09c74856fc39572b31c" ]); then
                    mkdir -p cmake
                    cp ${ROOT}/CPM_0.38.5.cmake cmake
                fi
                if !([ -f _deps/eigen-subbuild/eigen-populate-prefix/src/eigen-3.4.0.tar.bz2 ] && [ "$(sha256sum _deps/eigen-subbuild/eigen-populate-prefix/src/eigen-3.4.0.tar.bz2 | awk '{print $1}')" == "b4c198460eba6f28d34894e3a5710998818515104d6e74e5cc331ce31e46e626" ]); then
                    mkdir -p _deps/eigen-subbuild/eigen-populate-prefix/src
                    cp ${ROOT}/eigen-3.4.0.tar.bz2 _deps/eigen-subbuild/eigen-populate-prefix/src
                fi
            fi
            ${@:4} && cmake --build . -j$2 && cmake --install .
        else
            cmake --build . -j$2 && cmake --install .
        fi
        popd
    fi
}

echo "BUILD_PYQUDA=${BUILD_PYQUDA}"

build_quda ${BUILD_PYQUDA} ${QUDA_JOBS} pyquda-${GPU_TARGET} \
    cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=RELEASE -DQUDA_BUILD_SHAREDLIB=ON \
    -DQUDA_TARGET_TYPE=HIP -DAMDGPU_TARGETS=${GPU_TARGET} -DGPU_TARGETS=${GPU_TARGET} \
    -DQUDA_GPU_ARCH=${GPU_TARGET} -DQUDA_HETEROGENEOUS_ATOMIC=${HETEROGENEOUS_ATOMIC} \
    -DQUDA_MPI=ON \
    -DQUDA_COVDEV=ON -DQUDA_MULTIGRID=ON \
    -DQUDA_CLOVER_DYNAMIC=OFF -DQUDA_CLOVER_RECONSTRUCT=OFF \
    -DQUDA_DIRAC_DEFAULT_OFF=ON -DQUDA_DIRAC_WILSON=ON -DQUDA_DIRAC_CLOVER=ON -DQUDA_DIRAC_STAGGERED=ON -DQUDA_DIRAC_LAPLACE=ON \
    -DCMAKE_INSTALL_PREFIX=${DST}/pyquda-${GPU_TARGET} ${SRC}/quda
    # -DQUDA_MULTIGRID_NVEC_LIST="6,24,32,64,96" \

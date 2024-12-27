#!/usr/bin/env bash

BUILD_SHAREDLIB=ON
GPU_ARCH=sm_70
HETEROGENEOUS_ATOMIC=ON
JOBS=32
QUDA_JOBS=32
OFFLINE=1

# 0: Nothing; 1: Build and install; 2: Configure, build and install; 3: Clean, configure, build and install.
BUILD_PYQUDA=2

ROOT=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
SRC=${ROOT}
BIN=${ROOT}/build
DST=${ROOT}/install

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
                if !([ -f cmake/CPM_0.40.2.cmake ] && [ "$(sha256sum cmake/CPM_0.40.2.cmake | awk '{print $1}')" == "c8cdc32c03816538ce22781ed72964dc864b2a34a310d3b7104812a5ca2d835d" ]); then
                    mkdir -p cmake
                    cp ${ROOT}/CPM_0.40.2.cmake cmake
                fi
                if !([ -f _deps/eigen-subbuild/eigen-populate-prefix/src/e67c494cba7180066e73b9f6234d0b2129f1cdf5.tar.bz2 ] && [ "$(sha256sum _deps/eigen-subbuild/eigen-populate-prefix/src/e67c494cba7180066e73b9f6234d0b2129f1cdf5.tar.bz2 | awk '{print $1}')" == "98d244932291506b75c4ae7459af29b1112ea3d2f04660686a925d9ef6634583" ]); then
                    mkdir -p _deps/eigen-subbuild/eigen-populate-prefix/src
                    cp ${ROOT}/e67c494cba7180066e73b9f6234d0b2129f1cdf5.tar.bz2 _deps/eigen-subbuild/eigen-populate-prefix/src
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
echo "GPU_ARCH=${GPU_ARCH}"

build_quda ${BUILD_PYQUDA} ${QUDA_JOBS} pyquda-${GPU_ARCH} \
    cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=RELEASE -DQUDA_BUILD_SHAREDLIB=ON \
    -DQUDA_GPU_ARCH=${GPU_ARCH} -DQUDA_HETEROGENEOUS_ATOMIC=${HETEROGENEOUS_ATOMIC} \
    -DQUDA_MPI=ON \
    -DQUDA_COVDEV=ON -DQUDA_MULTIGRID=ON \
    -DQUDA_CLOVER_DYNAMIC=OFF -DQUDA_CLOVER_RECONSTRUCT=OFF \
    -DQUDA_DIRAC_DEFAULT_OFF=ON -DQUDA_DIRAC_WILSON=ON -DQUDA_DIRAC_CLOVER=ON -DQUDA_DIRAC_STAGGERED=ON -DQUDA_DIRAC_LAPLACE=ON \
    -DCMAKE_INSTALL_PREFIX=${DST}/pyquda-${GPU_ARCH} ${SRC}/quda
    # -DQUDA_MULTIGRID_NVEC_LIST="6,24,32,64,96" \

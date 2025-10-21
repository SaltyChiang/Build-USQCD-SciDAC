#!/usr/bin/env bash

SHARED_LIBS=ON
CPU_ARCH=x86_64
GPU_ARCH=
LLVM_VERSION=
OFFLINE=1
JOBS=$(nproc)

# 0: Nothing; 1: Build and install; 2: Configure, build and install; 3: Clean, configure, build and install.
BUILD_CHROMA=2

source ./common.sh

build ${BUILD_QMP} qmp qmp \
    -DQMP_MPI=ON \

build ${BUILD_QDPXX} qdpxx qdpxx \
    -DQMP_DIR=${DST}/qmp/lib/cmake/QMP \

build ${BUILD_CHROMA} chroma chroma \
    -DQMP_DIR=${DST}/qmp/lib/cmake/QMP -DQDPXX_DIR=${DST}/qdpxx/lib/cmake/QDPXX \

build ${BUILD_QDPXX} qdpxx-openmp qdpxx \
    -DQDP_USE_OPENMP=ON \
    -DQMP_DIR=${DST}/qmp/lib/cmake/QMP \

build ${BUILD_CHROMA} chroma-openmp chroma \
    -DChroma_ENABLE_OPENMP=ON \
    -DQMP_DIR=${DST}/qmp/lib/cmake/QMP -DQDPXX_DIR=${DST}/qdpxx-openmp/lib/cmake/QDPXX \

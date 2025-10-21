#!/usr/bin/env bash

SHARED_LIBS=ON
CPU_ARCH=x86_64
GPU_ARCH=sm_60
LLVM_VERSION=14
OFFLINE=1
JOBS=$(nproc)

# 0: Nothing; 1: Build and install; 2: Configure, build and install; 3: Clean, configure, build and install.
BUILD_CHROMA=2
BUILD_CHROMA_JIT=2
BUILD_MILC=2
BUILD_PYQUDA=2

source ./common.sh

build ${BUILD_QMP} qmp qmp \
    -DQMP_MPI=ON

build ${BUILD_QDPXX} qdpxx qdpxx \
    -DQMP_DIR=${DST}/qmp/lib/cmake/QMP

build_quda ${BUILD_QUDA} quda-${GPU_ARCH} quda \
    -DQUDA_QMP=ON -DQUDA_QIO=ON \
    -DQMP_DIR=${DST}/qmp/lib/cmake/QMP -DQIO_DIR=${DST}/qdpxx/lib/cmake/QIO

build ${BUILD_CHROMA} chroma-${GPU_ARCH} chroma \
    -DChroma_ENABLE_QUDA=ON \
    -DQMP_DIR=${DST}/qmp/lib/cmake/QMP -DQDPXX_DIR=${DST}/qdpxx/lib/cmake/QDPXX -DQUDA_DIR=${DST}/quda-${GPU_ARCH}/lib/cmake/QUDA

build ${BUILD_QDP_JIT} qdp-jit qdp-jit \
    -DQDP_ENABLE_LLVM${LLVM_VERSION}=ON \
    -DQMP_DIR=${DST}/qmp/lib/cmake/QMP

build_quda ${BUILD_QUDA_JIT} quda-jit-${GPU_ARCH} quda \
    -DQUDA_QMP=ON -DQUDA_QIO=ON -DQUDA_QDPJIT=ON -DQUDA_INTERFACE_QDPJIT=ON -DQUDA_BUILD_ALL_TESTS=OFF \
    -DQMP_DIR=${DST}/qmp/lib/cmake/QMP -DQIO_DIR=${DST}/qdp-jit/lib/cmake/QIO -DQDPXX_DIR=${DST}/qdp-jit/lib/cmake/QDPXX

build ${BUILD_CHROMA_JIT} chroma-jit-${GPU_ARCH} chroma \
    -DChroma_ENABLE_JIT_CLOVER=ON -DChroma_ENABLE_QUDA=ON \
    -DQMP_DIR=${DST}/qmp/lib/cmake/QMP -DQDPXX_DIR=${DST}/qdp-jit/lib/cmake/QDPXX -DQUDA_DIR=${DST}/quda-jit-${GPU_ARCH}/lib/cmake/QUDA

build_quda ${BUILD_PYQUDA} pyquda-${GPU_ARCH} quda \
    -DQUDA_MPI=ON
    # -DQUDA_MULTIGRID_NVEC_LIST="6,24,32,64,96" \

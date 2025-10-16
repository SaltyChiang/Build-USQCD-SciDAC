#!/usr/bin/env bash

SHARED_LIBS=ON
CPU_ARCH=x86_64
GPU_ARCH=sm_60
LLVM_VERSION=14
JOBS=32
OFFLINE=1

# 0: Nothing; 1: Build and install; 2: Configure, build and install; 3: Clean, configure, build and install.
BUILD_CHROMA=2
BUILD_CHROMA_JIT=2
BUILD_MILC=2
BUILD_PYQUDA=2

ROOT=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
SRC=${ROOT}
BIN=${ROOT}/build
DST=${ROOT}/install

function build() {
    if [ $1 -gt 0 ]; then
        mkdir -p ${BIN}/$2
        pushd ${BIN}/$2
        if [ $1 -gt 1 ]; then
            rm -rf CMakeCache.txt
            if [ $1 -gt 2 ]; then
                rm -rf ./*
            fi
            cmake -DCMAKE_INSTALL_PREFIX=${DST}/$2 ${SRC}/$3 \
                -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=${SHARED_LIBS} \
                -DCMAKE_INSTALL_RPATH=${DST}/$2/lib -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=True \
                ${@:4} && \
            cmake --build . -j${JOBS} && cmake --install .
        else
            cmake --build . -j${JOBS} && cmake --install .
        fi
        popd
    fi
}

function build_quda() {
    if [ $1 -gt 0 ]; then
        mkdir -p ${BIN}/$2
        pushd ${BIN}/$2
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
            cmake -DCMAKE_INSTALL_PREFIX=${DST}/$2 ${SRC}/$3 \
                -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=RELEASE -DQUDA_BUILD_SHAREDLIB=${SHARED_LIBS} \
                -DQUDA_GPU_ARCH=${GPU_ARCH} \
                -DQUDA_CLOVER_DYNAMIC=OFF -DQUDA_CLOVER_RECONSTRUCT=OFF -DQUDA_DIRAC_DEFAULT_OFF=ON \
                -DQUDA_DIRAC_WILSON=${QUDA_WILSON_CLOVER} -DQUDA_DIRAC_CLOVER=${QUDA_WILSON_CLOVER} \
                -DQUDA_DIRAC_DOMAIN_WALL=${QUDA_DOMAIN_WALL} -DQUDA_DIRAC_STAGGERED=${QUDA_STAGGERED} \
                -DQUDA_DIRAC_TWISTED_MASS=${QUDA_TWISTED} -DQUDA_DIRAC_TWISTED_CLOVER=${QUDA_TWISTED} \
                -DQUDA_DIRAC_LAPLACE=${QUDA_LAPLACE_COVDEV} -DQUDA_DIRAC_COVDEV=${QUDA_LAPLACE_COVDEV} \
                -DQUDA_MULTIGRID=${QUDA_MULTIGRID} \
                ${@:4} && \
            cmake --build . -j${JOBS} && cmake --install .
        else
            cmake --build . -j${JOBS} && cmake --install .
        fi
        popd
    fi
}

BUILD_QMP=0
BUILD_QDPXX=0
BUILD_QUDA=0
BUILD_QDP_JIT=0
BUILD_QUDA_JIT=0

QUDA_WILSON_CLOVER=OFF
QUDA_DOMAIN_WALL=OFF
QUDA_STAGGERED=OFF
QUDA_TWISTED=OFF
QUDA_LAPLACE_COVDEV=OFF
QUDA_MULTIGRID=OFF

if [ ${BUILD_CHROMA} -gt 0 ]; then
    BUILD_QMP=$((${BUILD_CHROMA} > ${BUILD_QMP} ? ${BUILD_CHROMA} : ${BUILD_QMP}))
    BUILD_QDPXX=$((${BUILD_CHROMA} > ${BUILD_QDPXX} ? ${BUILD_CHROMA} : ${BUILD_QDPXX}))
    BUILD_QUDA=$((${BUILD_CHROMA} > ${BUILD_QUDA} ? ${BUILD_CHROMA} : ${BUILD_QUDA}))
    QUDA_WILSON_CLOVER=ON
    QUDA_DOMAIN_WALL=ON
    QUDA_MULTIGRID=ON
fi

if [ ${BUILD_CHROMA_JIT} -gt 0 ]; then
    BUILD_QMP=$((${BUILD_CHROMA_JIT} > ${BUILD_QMP} ? ${BUILD_CHROMA_JIT} : ${BUILD_QMP}))
    BUILD_QDP_JIT=$((${BUILD_CHROMA_JIT} > ${BUILD_QDP_JIT} ? ${BUILD_CHROMA_JIT} : ${BUILD_QDP_JIT}))
    BUILD_QUDA_JIT=$((${BUILD_CHROMA_JIT} > ${BUILD_QUDA_JIT} ? ${BUILD_CHROMA_JIT} : ${BUILD_QUDA_JIT}))
    QUDA_WILSON_CLOVER=ON
    QUDA_DOMAIN_WALL=ON
    QUDA_MULTIGRID=ON
fi

if [ ${BUILD_MILC} -gt 0 ]; then
    BUILD_QMP=$((${BUILD_MILC} > ${BUILD_QMP} ? ${BUILD_MILC} : ${BUILD_QMP}))
    BUILD_QDPXX=$((${BUILD_MILC} > ${BUILD_QDPXX} ? ${BUILD_MILC} : ${BUILD_QDPXX}))
    BUILD_QUDA=$((${BUILD_MILC} > ${BUILD_QUDA} ? ${BUILD_MILC} : ${BUILD_QUDA}))
    QUDA_STAGGERED=ON
fi

if [ ${BUILD_PYQUDA} -gt 0 ]; then
    SHARED_LIBS=ON
    QUDA_WILSON_CLOVER=ON
    QUDA_STAGGERED=ON
    QUDA_LAPLACE_COVDEV=ON
    QUDA_MULTIGRID=ON
fi

echo "SHARED_LIBS=${SHARED_LIBS}"
echo "CPU_ARCH=${CPU_ARCH}"
echo "GPU_ARCH=${GPU_ARCH}"
echo "BUILD_QMP=${BUILD_QMP}"
echo "BUILD_QDPXX=${BUILD_QDPXX}"
echo "BUILD_QDP_JIT=${BUILD_QDP_JIT}"
echo "BUILD_QUDA=${BUILD_QUDA}"
echo "BUILD_QUDA_JIT=${BUILD_QUDA_JIT}"
echo "BUILD_CHROMA=${BUILD_CHROMA}"
echo "BUILD_CHROMA_JIT=${BUILD_CHROMA_JIT}"
echo "BUILD_MILC=${BUILD_MILC}"
echo "BUILD_PYQUDA=${BUILD_PYQUDA}"

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

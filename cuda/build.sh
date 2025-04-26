#!/usr/bin/env bash

BUILD_SHAREDLIB=ON
CPU_ARCH=x86_64
GPU_ARCH=sm_70
LLVM_VERSION=14
ENABLE_QUDA=ON
JOBS=32
QUDA_JOBS=32
OFFLINE=1

# 0: Nothing; 1: Build and install; 2: Configure, build and install; 3: Clean, configure, build and install.
BUILD_CHROMA=2
BUILD_CHROMA_JIT=2
BUILD_PYQUDA=2

ROOT=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
SRC=${ROOT}
BIN=${ROOT}/build
DST=${ROOT}/install

function build() {
    if [ $1 -gt 0 ]; then
        mkdir -p ${BIN}/$3
        pushd ${BIN}/$3
        if [ $1 -gt 1 ]; then
            rm -rf CMakeCache.txt
            if [ $1 -gt 2 ]; then
                rm -rf ./*
            fi
            ${@:4} && cmake --build . -j$2 && cmake --install .
        else
            cmake --build . -j$2 && cmake --install .
        fi
        popd
    fi
}

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

BUILD_QMP=0
BUILD_QDPXX=0
BUILD_QDP_JIT=0
BUILD_QUDA_JIT=0

if [ ${BUILD_CHROMA} -gt 0 ]; then
    BUILD_QMP=$((${BUILD_CHROMA} > ${BUILD_QMP} ? ${BUILD_CHROMA} : ${BUILD_QMP}))
    BUILD_QDPXX=$((${BUILD_CHROMA} > ${BUILD_QDPXX} ? ${BUILD_CHROMA} : ${BUILD_QDPXX}))
fi

if [ ${BUILD_CHROMA_JIT} -gt 0 ]; then
    BUILD_QMP=$((${BUILD_CHROMA_JIT} > ${BUILD_QMP} ? ${BUILD_CHROMA_JIT} : ${BUILD_QMP}))
    BUILD_QDP_JIT=$((${BUILD_CHROMA_JIT} > ${BUILD_QDP_JIT} ? ${BUILD_CHROMA_JIT} : ${BUILD_QDP_JIT}))
    BUILD_QUDA_JIT=$((${BUILD_CHROMA_JIT} > ${BUILD_QUDA_JIT} ? ${BUILD_CHROMA_JIT} : ${BUILD_QUDA_JIT}))
fi

if [ ${ENABLE_QUDA} = OFF ]; then
    BUILD_QUDA_JIT=0
    BUILD_PYQUDA=0
fi

echo "BUILD_QMP=${BUILD_QMP}"
echo "BUILD_QDPXX=${BUILD_QDPXX}"
echo "BUILD_QDP_JIT=${BUILD_QDP_JIT}"
echo "BUILD_QUDA_JIT=${BUILD_QUDA_JIT}"
echo "BUILD_CHROMA=${BUILD_CHROMA}"
echo "BUILD_CHROMA_JIT=${BUILD_CHROMA_JIT}"
echo "BUILD_PYQUDA=${BUILD_PYQUDA}"
echo "CPU_ARCH=${CPU_ARCH}"
echo "GPU_ARCH=${GPU_ARCH}"

build ${BUILD_QMP} ${JOBS} qmp \
    cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=${BUILD_SHAREDLIB} \
    -DQMP_MPI=ON \
    -DCMAKE_INSTALL_RPATH=${DST}/qmp/lib -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=True \
    -DCMAKE_INSTALL_PREFIX=${DST}/qmp ${SRC}/qmp

build ${BUILD_QDPXX} ${JOBS} qdpxx \
    cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=${BUILD_SHAREDLIB} \
    -DQDP_USE_OPENMP=ON \
    -DQMP_DIR=${DST}/qmp/lib/cmake/QMP \
    -DCMAKE_INSTALL_RPATH=${DST}/qdpxx/lib -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=True \
    -DCMAKE_INSTALL_PREFIX=${DST}/qdpxx ${SRC}/qdpxx

build ${BUILD_QDP_JIT} ${JOBS} qdp-jit \
    cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=${BUILD_SHAREDLIB} \
    -DQDP_ENABLE_LLVM${LLVM_VERSION}=ON \
    -DQMP_DIR=${DST}/qmp/lib/cmake/QMP \
    -DCMAKE_INSTALL_RPATH=${DST}/qdp-jit/lib -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=True \
    -DCMAKE_INSTALL_PREFIX=${DST}/qdp-jit ${SRC}/qdp-jit

build_quda ${BUILD_QUDA_JIT} ${QUDA_JOBS} quda-jit-${GPU_ARCH} \
    cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=RELEASE -DQUDA_BUILD_SHAREDLIB=${BUILD_SHAREDLIB} \
    -DQUDA_GPU_ARCH=${GPU_ARCH} \
    -DQUDA_MULTIGRID=ON \
    -DQUDA_QMP=ON -DQUDA_QIO=ON -DQUDA_QDPJIT=ON -DQUDA_INTERFACE_QDPJIT=ON -DQUDA_BUILD_ALL_TESTS=OFF \
    -DQMP_DIR=${DST}/qmp/lib/cmake/QMP -DQIO_DIR=${DST}/qdp-jit/lib/cmake/QIO -DQDPXX_DIR=${DST}/qdp-jit/lib/cmake/QDPXX \
    -DCMAKE_INSTALL_PREFIX=${DST}/quda-jit-${GPU_ARCH} ${SRC}/quda

build ${BUILD_CHROMA} ${JOBS} chroma-${CPU_ARCH} \
    cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=${BUILD_SHAREDLIB} \
    -DChroma_ENABLE_OPENMP=ON \
    -DQMP_DIR=${DST}/qmp/lib/cmake/QMP -DQDPXX_DIR=${DST}/qdpxx/lib/cmake/QDPXX \
    -DCMAKE_INSTALL_RPATH=${DST}/chroma-${CPU_ARCH}/lib -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=True \
    -DCMAKE_INSTALL_PREFIX=${DST}/chroma-${CPU_ARCH} ${SRC}/chroma

build ${BUILD_CHROMA_JIT} ${JOBS} chroma-jit-${GPU_ARCH} \
    cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=${BUILD_SHAREDLIB} \
    -DChroma_ENABLE_OPENMP=ON -DChroma_ENABLE_JIT_CLOVER=ON -DChroma_ENABLE_QUDA=${ENABLE_QUDA} \
    -DQMP_DIR=${DST}/qmp/lib/cmake/QMP -DQDPXX_DIR=${DST}/qdp-jit/lib/cmake/QDPXX -DQUDA_DIR=${DST}/quda-jit-${GPU_ARCH}/lib/cmake/QUDA \
    -DCMAKE_INSTALL_RPATH=${DST}/chroma-jit-${GPU_ARCH}/lib -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=True \
    -DCMAKE_INSTALL_PREFIX=${DST}/chroma-jit-${GPU_ARCH} ${SRC}/chroma

build_quda ${BUILD_PYQUDA} ${QUDA_JOBS} pyquda-${GPU_ARCH} \
    cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=RELEASE -DQUDA_BUILD_SHAREDLIB=ON \
    -DQUDA_TARGET_TYPE=HIP -DQUDA_GPU_ARCH=${GPU_ARCH} -DAMDGPU_TARGETS=${GPU_ARCH} -DGPU_TARGETS=${GPU_ARCH} \
    -DQUDA_MULTIGRID=ON \
    -DQUDA_COVDEV=ON -DQUDA_CLOVER_DYNAMIC=OFF -DQUDA_CLOVER_RECONSTRUCT=OFF \
    -DQUDA_DIRAC_DEFAULT_OFF=ON -DQUDA_DIRAC_WILSON=ON -DQUDA_DIRAC_CLOVER=ON -DQUDA_DIRAC_STAGGERED=ON -DQUDA_DIRAC_LAPLACE=ON \
    -DQUDA_MPI=ON \
    -DCMAKE_INSTALL_PREFIX=${DST}/pyquda-${GPU_ARCH} ${SRC}/quda
    # -DQUDA_MULTIGRID_NVEC_LIST="6,24,32,64,96" \

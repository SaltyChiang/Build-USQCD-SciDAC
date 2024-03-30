#!/usr/bin/env bash

BUILD_SHAREDLIB=ON
GPU_TARGET=sm_70
HETEROGENEOUS_ATOMIC=ON
LLVM_VERSION=16
JOBS=32
QUDA_JOBS=32

ROOT=$HOME/scidac
SRC=${ROOT}
BIN=${ROOT}/build
DST=${ROOT}/install

# 0: Nothing; 1: Build and install; 2: Configure, build and install; 3: Clean, configure, build and install.
BUILD_PYQUDA=2
BUILD_CHROMA=2
BUILD_CHROMA_JIT=2

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

function prepare_quda() {
    if [ $1 -gt 0 ]; then
        mkdir -p ${BIN}/$2
        pushd ${BIN}/$2
        mkdir -p cmake
        cp ${ROOT}/CPM_0.38.5.cmake cmake
        mkdir -p _deps/eigen-subbuild/eigen-populate-prefix/src
        cp ${ROOT}/eigen-3.4.0.tar.bz2 _deps/eigen-subbuild/eigen-populate-prefix/src
        popd
    fi
}

BUILD_QMP=0
BUILD_QDPXX=0
BUILD_QDP_JIT=0
BUILD_QUDA=0
BUILD_QUDA_JIT=0

if [ ${BUILD_PYQUDA} -gt 0 ]; then
    :
fi

if [ ${BUILD_CHROMA} -gt 0 ]; then
    BUILD_QMP=$((${BUILD_CHROMA} > ${BUILD_QMP} ? ${BUILD_CHROMA} : ${BUILD_QMP}))
    BUILD_QDPXX=$((${BUILD_CHROMA} > ${BUILD_QDPXX} ? ${BUILD_CHROMA} : ${BUILD_QDPXX}))
    BUILD_QUDA=$((${BUILD_CHROMA} > ${BUILD_QUDA} ? ${BUILD_CHROMA} : ${BUILD_QUDA}))
fi

if [ ${BUILD_CHROMA_JIT} -gt 0 ]; then
    BUILD_QMP=$((${BUILD_CHROMA_JIT} > ${BUILD_QMP} ? ${BUILD_CHROMA_JIT} : ${BUILD_QMP}))
    BUILD_QDPXX=$((${BUILD_CHROMA_JIT} > ${BUILD_QDPXX} ? ${BUILD_CHROMA_JIT} : ${BUILD_QDPXX}))
    BUILD_QDP_JIT=$((${BUILD_CHROMA_JIT} > ${BUILD_QDP_JIT} ? ${BUILD_CHROMA_JIT} : ${BUILD_QDP_JIT}))
    BUILD_QUDA_JIT=$((${BUILD_CHROMA_JIT} > ${BUILD_QUDA_JIT} ? ${BUILD_CHROMA_JIT} : ${BUILD_QUDA_JIT}))
fi

echo "BUILD_QMP=${BUILD_QMP}"
echo "BUILD_QDPXX=${BUILD_QDPXX}"
echo "BUILD_QDP_JIT=${BUILD_QDP_JIT}"
echo "BUILD_QUDA=${BUILD_QUDA}"
echo "BUILD_QUDA_JIT=${BUILD_QUDA_JIT}"
echo "BUILD_PYQUDA=${BUILD_PYQUDA}"
echo "BUILD_CHROMA=${BUILD_CHROMA}"
echo "BUILD_CHROMA_JIT=${BUILD_CHROMA_JIT}"

build ${BUILD_QMP} ${JOBS} qmp \
    cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_POSITION_INDEPENDENT_CODE=${BUILD_SHAREDLIB} \
    -DQMP_MPI=ON \
    -DCMAKE_INSTALL_PREFIX=${DST}/qmp ${SRC}/qmp

build ${BUILD_QDPXX} ${JOBS} qdpxx \
    cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_POSITION_INDEPENDENT_CODE=${BUILD_SHAREDLIB} \
    -DQDP_USE_OPENMP=ON \
    -DQMP_DIR=${DST}/qmp/lib/cmake/QMP \
    -DCMAKE_INSTALL_PREFIX=${DST}/qdpxx ${SRC}/qdpxx

build ${BUILD_QDP_JIT} ${JOBS} qdp-jit \
    cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=${BUILD_SHAREDLIB} \
    -DQDP_ENABLE_LLVM${LLVM_VERSION}=ON \
    -DQMP_DIR=${DST}/qmp/lib/cmake/QMP \
    -DCMAKE_INSTALL_RPATH=${DST}/qdp-jit/lib -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=True \
    -DCMAKE_INSTALL_PREFIX=${DST}/qdp-jit ${SRC}/qdp-jit

prepare_quda ${BUILD_PYQUDA} quda
build ${BUILD_QUDA} ${QUDA_JOBS} quda \
    cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=RELEASE -DQUDA_BUILD_SHAREDLIB=${BUILD_SHAREDLIB} \
    -DQUDA_GPU_ARCH=${GPU_TARGET} -DQUDA_HETEROGENEOUS_ATOMIC=${HETEROGENEOUS_ATOMIC} \
    -DQUDA_QMP=ON -DQUDA_QIO=ON \
    -DQUDA_LAPLACE=ON -DQUDA_MULTIGRID=ON \
    -DQMP_DIR=${DST}/qmp/lib/cmake/QMP -DQIO_DIR=${DST}/qdpxx/lib/cmake/QIO \
    -DCMAKE_INSTALL_PREFIX=${DST}/quda ${SRC}/quda

prepare_quda ${BUILD_PYQUDA} quda-jit
build ${BUILD_QUDA_JIT} ${QUDA_JOBS} quda-jit \
    cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=RELEASE -DQUDA_BUILD_SHAREDLIB=${BUILD_SHAREDLIB} \
    -DQUDA_GPU_ARCH=${GPU_TARGET} -DQUDA_HETEROGENEOUS_ATOMIC=${HETEROGENEOUS_ATOMIC} \
    -DQUDA_QMP=ON -DQUDA_QIO=ON \
    -DQUDA_QDPJIT=ON -DQUDA_INTERFACE_QDPJIT=ON -DQUDA_BUILD_ALL_TESTS=OFF \
    -DQUDA_LAPLACE=ON -DQUDA_MULTIGRID=ON \
    -DQMP_DIR=${DST}/qmp/lib/cmake/QMP -DQIO_DIR=${DST}/qdpxx/lib/cmake/QIO -DQDPXX_DIR=${DST}/qdp-jit/lib/cmake/QDPXX \
    -DCMAKE_INSTALL_PREFIX=${DST}/quda-jit ${SRC}/quda

prepare_quda ${BUILD_PYQUDA} pyquda
build ${BUILD_PYQUDA} ${QUDA_JOBS} pyquda \
    cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=RELEASE -DQUDA_BUILD_SHAREDLIB=ON \
    -DQUDA_GPU_ARCH=${GPU_TARGET} -DQUDA_HETEROGENEOUS_ATOMIC=${HETEROGENEOUS_ATOMIC} \
    -DQUDA_MPI=ON \
    -DQUDA_CLOVER_DYNAMIC=OFF -DQUDA_CLOVER_RECONSTRUCT=OFF \
    -DQUDA_DIRAC_CLOVER_HASENBUSCH=OFF -DQUDA_DIRAC_DOMAIN_WALL=OFF \
    -DQUDA_DIRAC_TWISTED_CLOVER=OFF -DQUDA_DIRAC_TWISTED_MASS=OFF -DQUDA_DIRAC_NDEG_TWISTED_CLOVER=OFF -DQUDA_DIRAC_NDEG_TWISTED_MASS=OFF \
    -DQUDA_LAPLACE=ON -DQUDA_MULTIGRID=ON \
    -DQUDA_MULTIGRID_NVEC_LIST="6,24,32,64,96" \
    -DCMAKE_INSTALL_PREFIX=${DST}/pyquda ${SRC}/quda

build ${BUILD_CHROMA} ${JOBS} chroma \
    cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=${BUILD_SHAREDLIB} \
    -DChroma_ENABLE_OPENMP=ON -DChroma_ENABLE_QUDA=ON \
    -DQMP_DIR=${DST}/qmp/lib/cmake/QMP -DQDPXX_DIR=${DST}/qdpxx/lib/cmake/QDPXX -DQUDA_DIR=${DST}/quda/lib/cmake/QUDA \
    -DCMAKE_INSTALL_RPATH=${DST}/chroma/lib -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=True \
    -DCMAKE_INSTALL_PREFIX=${DST}/chroma ${SRC}/chroma

build ${BUILD_CHROMA_JIT} ${JOBS} chroma-jit \
    cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=${BUILD_SHAREDLIB} \
    -DChroma_ENABLE_OPENMP=ON -DChroma_ENABLE_JIT_CLOVER=ON -DChroma_ENABLE_QUDA=ON \
    -DQMP_DIR=${DST}/qmp/lib/cmake/QMP -DQDPXX_DIR=${DST}/qdp-jit/lib/cmake/QDPXX -DQUDA_DIR=${DST}/quda-jit/lib/cmake/QUDA \
    -DCMAKE_INSTALL_RPATH=${DST}/chroma-jit/lib -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=True \
    -DCMAKE_INSTALL_PREFIX=${DST}/chroma-jit ${SRC}/chroma

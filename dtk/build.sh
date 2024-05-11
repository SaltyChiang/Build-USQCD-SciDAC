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

BUILD_QMP=0
BUILD_QDPXX=0
BUILD_QDP_JIT=0
BUILD_QUDA=0
BUILD_QUDA_JIT=0

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
echo "BUILD_CHROMA=${BUILD_CHROMA}"
echo "BUILD_CHROMA_JIT=${BUILD_CHROMA_JIT}"

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
    -DQDP_ENABLE_BACKEND=ROCM -DAMDGPU_TARGETS=${GPU_TARGET} -DGPU_TARGETS=${GPU_TARGET} \
    -DQDP_ENABLE_LLVM${LLVM_VERSION}=ON \
    -DQMP_DIR=${DST}/qmp/lib/cmake/QMP \
    -DCMAKE_INSTALL_RPATH=${DST}/qdp-jit/lib -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=True \
    -DCMAKE_INSTALL_PREFIX=${DST}/qdp-jit ${SRC}/qdp-jit

build_quda ${BUILD_QUDA} ${QUDA_JOBS} quda-${GPU_TARGET} \
    cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=RELEASE -DQUDA_BUILD_SHAREDLIB=${BUILD_SHAREDLIB} \
    -DQUDA_TARGET_TYPE=HIP -DAMDGPU_TARGETS=${GPU_TARGET} -DGPU_TARGETS=${GPU_TARGET} \
    -DQUDA_GPU_ARCH=${GPU_TARGET} -DQUDA_HETEROGENEOUS_ATOMIC=${HETEROGENEOUS_ATOMIC} \
    -DQUDA_QMP=ON -DQUDA_QIO=ON \
    -DQUDA_LAPLACE=ON -DQUDA_MULTIGRID=ON \
    -DQMP_DIR=${DST}/qmp/lib/cmake/QMP -DQIO_DIR=${DST}/qdpxx/lib/cmake/QIO \
    -DCMAKE_INSTALL_PREFIX=${DST}/quda-${GPU_TARGET} ${SRC}/quda

build_quda ${BUILD_QUDA_JIT} ${QUDA_JOBS} quda-jit-${GPU_TARGET} \
    cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=RELEASE -DQUDA_BUILD_SHAREDLIB=${BUILD_SHAREDLIB} \
    -DQUDA_TARGET_TYPE=HIP -DAMDGPU_TARGETS=${GPU_TARGET} -DGPU_TARGETS=${GPU_TARGET} \
    -DQUDA_GPU_ARCH=${GPU_TARGET} -DQUDA_HETEROGENEOUS_ATOMIC=${HETEROGENEOUS_ATOMIC} \
    -DQUDA_QMP=ON -DQUDA_QIO=ON \
    -DQUDA_QDPJIT=ON -DQUDA_INTERFACE_QDPJIT=ON -DQUDA_BUILD_ALL_TESTS=OFF \
    -DQUDA_LAPLACE=ON -DQUDA_MULTIGRID=ON \
    -DQMP_DIR=${DST}/qmp/lib/cmake/QMP -DQIO_DIR=${DST}/qdpxx/lib/cmake/QIO -DQDPXX_DIR=${DST}/qdp-jit/lib/cmake/QDPXX \
    -DCMAKE_INSTALL_PREFIX=${DST}/quda-jit-${GPU_TARGET} ${SRC}/quda

build ${BUILD_CHROMA} ${JOBS} chroma-${GPU_TARGET} \
    cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=${BUILD_SHAREDLIB} \
    -DChroma_ENABLE_OPENMP=ON -DChroma_ENABLE_QUDA=ON \
    -DQMP_DIR=${DST}/qmp/lib/cmake/QMP -DQDPXX_DIR=${DST}/qdpxx/lib/cmake/QDPXX -DQUDA_DIR=${DST}/quda-${GPU_TARGET}/lib/cmake/QUDA \
    -DCMAKE_INSTALL_RPATH=${DST}/chroma-${GPU_TARGET}/lib -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=True \
    -DCMAKE_INSTALL_PREFIX=${DST}/chroma-${GPU_TARGET} ${SRC}/chroma

build ${BUILD_CHROMA_JIT} ${JOBS} chroma-jit-${GPU_TARGET} \
    cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=${BUILD_SHAREDLIB} \
    -DCMAKE_HIP_ARCHITECTURES=${GPU_TARGET} -DAMDGPU_TARGETS=${GPU_TARGET} -DGPU_TARGETS=${GPU_TARGET} \
    -DChroma_ENABLE_OPENMP=ON -DChroma_ENABLE_JIT_CLOVER=ON -DChroma_ENABLE_QUDA=ON \
    -DQMP_DIR=${DST}/qmp/lib/cmake/QMP -DQDPXX_DIR=${DST}/qdp-jit/lib/cmake/QDPXX -DQUDA_DIR=${DST}/quda-jit-${GPU_TARGET}/lib/cmake/QUDA \
    -DCMAKE_INSTALL_RPATH=${DST}/chroma-jit-${GPU_TARGET}/lib -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=True \
    -DCMAKE_INSTALL_PREFIX=${DST}/chroma-jit-${GPU_TARGET} ${SRC}/chroma

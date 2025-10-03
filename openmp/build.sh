#!/usr/bin/env bash

BUILD_SHAREDLIB=ON
CPU_ARCH=x86_64
JOBS=32

# 0: Nothing; 1: Build and install; 2: Configure, build and install; 3: Clean, configure, build and install.
BUILD_CHROMA=2

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
                -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=${BUILD_SHAREDLIB} \
                -DCMAKE_INSTALL_RPATH=${DST}/$2/lib -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=True \
                ${@:4} && \
        else
            cmake --build . -j${JOBS} && cmake --install .
        fi
        popd
    fi
}

BUILD_QMP=0
BUILD_QDPXX=0

if [ ${BUILD_CHROMA} -gt 0 ]; then
    BUILD_QMP=$((${BUILD_CHROMA} > ${BUILD_QMP} ? ${BUILD_CHROMA} : ${BUILD_QMP}))
    BUILD_QDPXX=$((${BUILD_CHROMA} > ${BUILD_QDPXX} ? ${BUILD_CHROMA} : ${BUILD_QDPXX}))
fi

echo "BUILD_SHAREDLIB=${BUILD_SHAREDLIB}"
echo "CPU_ARCH=${CPU_ARCH}"
echo "BUILD_QMP=${BUILD_QMP}"
echo "BUILD_QDPXX=${BUILD_QDPXX}"
echo "BUILD_CHROMA=${BUILD_CHROMA}"

build ${BUILD_QMP} qmp \
    -DQMP_MPI=ON \

build ${BUILD_QDPXX} qdpxx-openmp \
    -DQDP_USE_OPENMP=ON \
    -DQMP_DIR=${DST}/qmp/lib/cmake/QMP \

build ${BUILD_CHROMA} chroma-openmp \
    -DChroma_ENABLE_OPENMP=ON \
    -DQMP_DIR=${DST}/qmp/lib/cmake/QMP -DQDPXX_DIR=${DST}/qdpxx/lib/cmake/QDPXX \

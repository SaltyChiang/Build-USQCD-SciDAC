#!/usr/bin/env bash

BUILD_SHAREDLIB=ON
JOBS=32
QUDA_JOBS=32

ROOT=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
SRC=${ROOT}
BIN=${ROOT}/build
DST=${ROOT}/install

# 0: Nothing; 1: Build and install; 2: Configure, build and install; 3: Clean, configure, build and install.
BUILD_CHROMA_CPU=2

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

BUILD_QMP=0
BUILD_QDPXX=0

if [ ${BUILD_CHROMA_CPU} -gt 0 ]; then
    BUILD_QMP=$((${BUILD_CHROMA_CPU} > ${BUILD_QMP} ? ${BUILD_CHROMA_CPU} : ${BUILD_QMP}))
    BUILD_QDPXX=$((${BUILD_CHROMA_CPU} > ${BUILD_QDPXX} ? ${BUILD_CHROMA_CPU} : ${BUILD_QDPXX}))
fi

echo "BUILD_QMP=${BUILD_QMP}"
echo "BUILD_QDPXX=${BUILD_QDPXX}"
echo "BUILD_CHROMA_CPU=${BUILD_CHROMA_CPU}"

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

build ${BUILD_CHROMA_CPU} ${JOBS} chroma-cpu \
    cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=${BUILD_SHAREDLIB} \
    -DChroma_ENABLE_OPENMP=ON \
    -DQMP_DIR=${DST}/qmp/lib/cmake/QMP -DQDPXX_DIR=${DST}/qdpxx/lib/cmake/QDPXX \
    -DCMAKE_INSTALL_RPATH=${DST}/chroma-cpu/lib -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=True \
    -DCMAKE_INSTALL_PREFIX=${DST}/chroma-cpu ${SRC}/chroma

#!/usr/bin/env bash

function mkdir_cp_sha256() {
    # mkdir_cp_sha256 FILE DIR SHA256
    if !([ -f $2/$1 ] && [ "$(sha256sum $2/$1 | awk '{print $1}')" == "$3" ]); then
        mkdir -p $2
        cp ${SRC}/$1 $2
    fi
}

function build() {
    # build LEVEL DIR SRC [CMAKE_OPTIONS...]
    if [ $1 -gt 0 ]; then
        mkdir -p ${BIN}/$2
        echo "Enter ${BIN}/$2 (build)"
        cd ${BIN}/$2
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
        echo "Leave ${BIN}/$2 (build)"
        cd -
    fi
}

function build_quda() {
    # build_quda LEVEL DIR SRC [CMAKE_OPTIONS...]
    if [ $1 -gt 0 ]; then
        mkdir -p ${BIN}/$2
        echo "Enter ${BIN}/$2 (build_quda)"
        cd ${BIN}/$2
        if [ $1 -gt 1 ]; then
            rm -rf CMakeCache.txt
            if [ $1 -gt 2 ]; then
                rm -rf ./*
            fi
            if [ ${OFFLINE} -gt 0 ]; then
                mkdir_cp_sha256 CPM_0.40.2.cmake \
                    cmake \
                    c8cdc32c03816538ce22781ed72964dc864b2a34a310d3b7104812a5ca2d835d
                mkdir_cp_sha256 e67c494cba7180066e73b9f6234d0b2129f1cdf5.tar.bz2 \
                    _deps/eigen-subbuild/eigen-populate-prefix/src \
                    98d244932291506b75c4ae7459af29b1112ea3d2f04660686a925d9ef6634583
            fi
            cmake -DCMAKE_INSTALL_PREFIX=${DST}/$2 ${SRC}/$3 \
                -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=RELEASE -DQUDA_BUILD_SHAREDLIB=${SHARED_LIBS} \
                -DQUDA_GPU_ARCH=${GPU_ARCH} -DQUDA_DIRAC_DEFAULT_OFF=ON \
                -DQUDA_DIRAC_WILSON=${QUDA_CLOVER_WILSON} -DQUDA_DIRAC_CLOVER=${QUDA_CLOVER_WILSON} \
                -DQUDA_DIRAC_DOMAIN_WALL=${QUDA_DOMAIN_WALL} -DQUDA_DIRAC_STAGGERED=${QUDA_STAGGERED} \
                -DQUDA_DIRAC_TWISTED_MASS=${QUDA_TWISTED_CLOVER} -DQUDA_DIRAC_TWISTED_CLOVER=${QUDA_TWISTED_CLOVER} \
                -DQUDA_DIRAC_LAPLACE=${QUDA_LAPLACE} -DQUDA_DIRAC_COVDEV=${QUDA_COVDEV} \
                -DQUDA_CLOVER_DYNAMIC=${QUDA_CLOVER_DYNAMIC} -DQUDA_CLOVER_RECONSTRUCT=${QUDA_CLOVER_DYNAMIC} \
                -DQUDA_MULTIGRID=${QUDA_MULTIGRID} \
                ${@:4} && \
            cmake --build . -j${JOBS} && cmake --install .
        else
            cmake --build . -j${JOBS} && cmake --install .
        fi
        echo "Leave ${BIN}/$2 (build_quda)"
        cd -
    fi
}

if [ -z $GPU_ARCH ]; then
    BUILD_CHROMA_JIT=0
    BUILD_MILC=0
    BUILD_PYQUDA=0
fi

if [ -z $LLVM_VERSION ]; then
    BUILD_CHROMA_JIT=0
fi

BUILD_QMP=0
BUILD_QDPXX=0
BUILD_QUDA=0
BUILD_QDP_JIT=0
BUILD_QUDA_JIT=0
BUILD_QUDA_MPI=0

QUDA_CLOVER_WILSON=OFF
QUDA_DOMAIN_WALL=OFF
QUDA_STAGGERED=OFF
QUDA_TWISTED_CLOVER=OFF
QUDA_LAPLACE=ON
QUDA_COVDEV=ON
QUDA_CLOVER_DYNAMIC=ON
QUDA_MULTIGRID=OFF

if [ ${BUILD_CHROMA} -gt 0 ]; then
    BUILD_QMP=$((${BUILD_CHROMA} > ${BUILD_QMP} ? ${BUILD_CHROMA} : ${BUILD_QMP}))
    BUILD_QDPXX=$((${BUILD_CHROMA} > ${BUILD_QDPXX} ? ${BUILD_CHROMA} : ${BUILD_QDPXX}))
    BUILD_QUDA=$((${BUILD_CHROMA} > ${BUILD_QUDA} ? ${BUILD_CHROMA} : ${BUILD_QUDA}))
    QUDA_CLOVER_WILSON=ON
    QUDA_DOMAIN_WALL=ON
    QUDA_MULTIGRID=ON
fi

if [ ${BUILD_CHROMA_JIT} -gt 0 ]; then
    BUILD_QMP=$((${BUILD_CHROMA_JIT} > ${BUILD_QMP} ? ${BUILD_CHROMA_JIT} : ${BUILD_QMP}))
    BUILD_QDP_JIT=$((${BUILD_CHROMA_JIT} > ${BUILD_QDP_JIT} ? ${BUILD_CHROMA_JIT} : ${BUILD_QDP_JIT}))
    BUILD_QUDA_JIT=$((${BUILD_CHROMA_JIT} > ${BUILD_QUDA_JIT} ? ${BUILD_CHROMA_JIT} : ${BUILD_QUDA_JIT}))
    QUDA_CLOVER_WILSON=ON
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
    BUILD_QUDA_MPI=$((${BUILD_PYQUDA} > ${BUILD_QUDA_MPI} ? ${BUILD_PYQUDA} : ${BUILD_QUDA_MPI}))
    SHARED_LIBS=ON
    QUDA_CLOVER_WILSON=ON
    QUDA_STAGGERED=ON
    QUDA_CLOVER_DYNAMIC=OFF
    QUDA_MULTIGRID=ON
fi

echo "SHARED_LIBS=${SHARED_LIBS}"
echo "CPU_ARCH=${CPU_ARCH}"
echo "GPU_ARCH=${GPU_ARCH}"
echo "LLVM_VERSION=${LLVM_VERSION}"
echo "BUILD_QMP=${BUILD_QMP}"
echo "BUILD_QDPXX=${BUILD_QDPXX}"
echo "BUILD_QDP_JIT=${BUILD_QDP_JIT}"
echo "BUILD_QUDA=${BUILD_QUDA}"
echo "BUILD_QUDA_JIT=${BUILD_QUDA_JIT}"
echo "BUILD_QUDA_MPI=${BUILD_QUDA_MPI}"
echo "BUILD_CHROMA=${BUILD_CHROMA}"
echo "BUILD_CHROMA_JIT=${BUILD_CHROMA_JIT}"
echo "BUILD_MILC=${BUILD_MILC}"
echo "BUILD_PYQUDA=${BUILD_PYQUDA}"

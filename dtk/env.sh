#!/usr/bin/env bash

module purge
module load compiler/cmake/3.23.3
module load compiler/devtoolset/7.3.1
module load mpi/hpcx/2.11.0/gcc-7.3.1

export SCIDAC=$(cd $(dirname ${BASH_SOURCE[0]:-${(%):-%x}}) && pwd)

module load compiler/dtk/25.04
export ROCM_HOME=${ROCM_PATH}
export CUPY_INSTALL_USE_HIP=1
export HCC_AMDGPU_TARGET=gfx906
export AMDGPU_TARGETS=gfx906

export CC=clang
export CXX=clang++
export HIPCC=dcc
export CFLAGS="-Wno-return-type -Wno-inconsistent-missing-override"
export CXXFLAGS="-Wno-return-type -Wno-inconsistent-missing-override"
export HIPFLAGS="-Wno-return-type -Wno-inconsistent-missing-override"

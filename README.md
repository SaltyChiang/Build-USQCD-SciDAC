# Build USQCD software (SciDAC Layers) on CLQCD clusters

This is a repository for those who want to build USQCD software (Chroma with QUDA and QDP-JIT enabled) on CLQCD clusters.

## Prerequisites

- Wget
- Git
- Make
- CMake 3.18+
- GCC 10+ (for C++20 standard)
- LLVM 14+
- NVCC 11+

### Debian/Ubuntu

```bash
sudo apt install git build-essential cmake llvm-dev nvidia-cuda-toolkit
```

If the default GCC is not compatible with the NVCC, you can use `cuda-gcc` and `cuda-g++` instead of original ones. Install them with

```bash
sudo apt install nvidia-cuda-toolkit-gcc
```

#### *Default GCC shipped with Ubuntu 22.04 LTS breaks the compilation along with NVCC. Use GCC 10 instead.*

Check [this](https://github.com/NVIDIA/nccl/issues/650) for more information.

## Usage

Download the source code anywhere you like:

```bash
./download.sh cuda
```

`cuda` here is the target you want to run on. `cuda` and `dtk` are avaliable options now.

The `download.sh` script will download, patch and archive the source code you need. Upload or move `scidac.tgz` to where you want and unarchive it. Then you can build the binary with `build.sh` or `build_offline.sh`:

```bash
tar -xzvf scidac.tgz
cd scidac
./build_offline.sh
```

## Options

You should change the values of some variables in `build_offline.sh`. The example below builds these softwares on a platform with 32 CPU cores (`JOBS` and `QUDA_JOBS`) and some sm_70 GPUs (`GPU_TARGET` term, which is NVIDIA Tesla V100). The libraries (libqdp, libchroma and libquda) are built into shared libraries (`BUILD_SHAREDLIB`). `LLVM_VERSION` indicates qdp-jit related executables and shared libraries are linked against LLVM 16.

```bash
BUILD_SHAREDLIB=ON
GPU_TARGET=sm_70
HETEROGENEOUS_ATOMIC=ON
LLVM_VERSION=16
JOBS=32
QUDA_JOBS=32
```

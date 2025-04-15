from hpccm.primitives import baseimage, environment, shell
from hpccm.building_blocks import *

Stage0 += baseimage(image="nvidia/cuda:12.8.1-devel-ubuntu22.04")

Stage0 += gnu()
Stage0 += cmake(eula=True)

Stage0 += mlnx_ofed()
Stage0 += gdrcopy()
Stage0 += knem()
Stage0 += xpmem()
Stage0 += ucx(version="1.18.0")
Stage0 += openmpi(infiniband=False, ucx=True, version="4.1.8")
Stage0 += environment(variables={"OMPI_ALLOW_RUN_AS_ROOT": 1, "OMPI_ALLOW_RUN_AS_ROOT_CONFIRM": 1})

Stage0 += python(devel=True, python2=False)
Stage0 += environment(variables={"DEB_PYTHON_INSTALL_LAYOUT": "deb_system"})
Stage0 += pip(pip="pip3", packages=["Cython", "mpi4py", "numpy", "scipy", "gmpy2", "cupy-cuda12x", "gvar", "lsqfit"])

Stage0 += hdf5(enable_parallel=True, enable_unsupported=True, toolchain=openmpi().toolchain)
Stage0 += environment(variables={"HDF5_MPI": "ON"})
Stage0 += shell(commands=["CC=mpicc pip3 --no-cache-dir install --no-binary=h5py h5py"])

# Stage0 += generic_cmake(
#     branch="develop",
#     cmake_opts=[
#         "-D CMAKE_BUILD_TYPE=RELEASE",
#         "-D QUDA_GPU_ARCH=sm_60",
#         "-D QUDA_MULTIGRID=ON",
#         "-D QUDA_COVDEV=ON",
#         "-D QUDA_CLOVER_DYNAMIC=OFF",
#         "-D QUDA_CLOVER_RECONSTRUCT=OFF",
#         "-D QUDA_DIRAC_DEFAULT_OFF=ON",
#         "-D QUDA_DIRAC_WILSON=ON",
#         "-D QUDA_DIRAC_CLOVER=ON",
#         "-D QUDA_DIRAC_STAGGERED=ON",
#         "-D QUDA_DIRAC_LAPLACE=ON",
#         "-D QUDA_MPI=ON",
#     ],
#     prefix="/usr/local/quda",
#     repository="https://github.com/lattice/quda.git",
# )
# Stage0 += environment(variables={"QUDA_PATH": "/usr/local/quda"})

# Stage1 += baseimage(image="nvidia/cuda:12.8.1-runtime-ubuntu22.04")
# Stage1 += Stage0.runtime()

#!/usr/bin/env bash

DIR=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
PYVENV=${DIR}/pyvenv

mkdir -p ${PYVENV}
pushd ${PYVENV}
wget https://files.pythonhosted.org/packages/b8/d6/ac9cd92ea2ad502ff7c1ab683806a9deb34711a1e2bd8a59814e8fc27e69/wheel-0.43.0.tar.gz -O wheel-0.43.0.tar.gz
wget https://files.pythonhosted.org/packages/2e/1a/1393e69df9cf7b04143a51776727dd048586781bca82543594ab439e2eb4/mpi4py-3.1.5.tar.gz -O mpi4py-3.1.5.tar.gz
wget https://files.pythonhosted.org/packages/89/4b/26357c444b48f3f4e3c17b999274e6c60f2367f7e9d454ca2280d8b463e1/fastrlock-0.8.2.tar.gz -O fastrlock-0.8.2.tar.gz
wget https://files.pythonhosted.org/packages/98/5d/5738903efe0ecb73e51eb44feafba32bdba2081263d40c5043568ff60faf/numpy-1.24.4-cp38-cp38-manylinux_2_17_x86_64.manylinux2014_x86_64.whl -O numpy-1.24.4-cp38-cp38-manylinux_2_17_x86_64.manylinux2014_x86_64.whl
wget https://files.pythonhosted.org/packages/7a/7c/d7b2a0417af6428440c0ad7cb9799073e507b1a465f827d058b826236964/numpy-1.24.4-cp39-cp39-manylinux_2_17_x86_64.manylinux2014_x86_64.whl -O numpy-1.24.4-cp39-cp39-manylinux_2_17_x86_64.manylinux2014_x86_64.whl
wget https://cancon.hpccube.com:65024/directlink/1/DTK-23.10.1_hpcapps-20240125/cupy/centos/cupy-12.0.0b3-cp38-cp38-linux_x86_64.whl -O cupy-12.0.0b3-cp38-cp38-linux_x86_64.whl
wget https://cancon.hpccube.com:65024/directlink/1/DTK-23.10.1_hpcapps-20240125/cupy/centos/cupy-12.0.0b3-cp39-cp39-linux_x86_64.whl -O cupy-12.0.0b3-cp39-cp39-linux_x86_64.whl
wget https://github.com/CLQCD/PyQUDA/releases/download/v0.6.16/PyQUDA-0.6.16.tar.gz -O PyQUDA-0.6.16.tar.gz
popd

pushd ${DIR}
cp pyvenv.sh pyvenv
tar -czf pyvenv.tgz pyvenv
popd

#!/usr/bin/env bash

DIR=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
PYVENV=${DIR}/pyvenv

mkdir -p ${PYVENV}
pushd ${PYVENV}
wget https://files.pythonhosted.org/packages/2e/1a/1393e69df9cf7b04143a51776727dd048586781bca82543594ab439e2eb4/mpi4py-3.1.5.tar.gz -O mpi4py-3.1.5.tar.gz
wget https://files.pythonhosted.org/packages/89/4b/26357c444b48f3f4e3c17b999274e6c60f2367f7e9d454ca2280d8b463e1/fastrlock-0.8.2.tar.gz -O fastrlock-0.8.2.tar.gz
wget https://cancon.hpccube.com:65024/directlink/1/DTK-23.10.1_hpcapps-20240125/cupy/centos/cupy-12.0.0b3-cp38-cp38-linux_x86_64.whl -O cupy-12.0.0b3-cp38-cp38-linux_x86_64.whl
wget https://cancon.hpccube.com:65024/directlink/1/DTK-23.10.1_hpcapps-20240125/cupy/centos/cupy-12.0.0b3-cp39-cp39-linux_x86_64.whl -O cupy-12.0.0b3-cp39-cp39-linux_x86_64.whl
wget https://github.com/CLQCD/PyQUDA/releases/download/v0.6.16/PyQUDA-0.6.16.tar.gz -O PyQUDA-0.6.16.tar.gz
popd

pushd ${DIR}
cp pyvenv.sh pyvenv
tar -czf pyvenv.tgz pyvenv
popd

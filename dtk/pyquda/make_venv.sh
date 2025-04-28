#!/usr/bin/env bash

PYTHON_MODULE=$1
if [ -z $PYTHON_MODULE ]; then
    echo "Error: Lack of parameters PYTHON_MODULE"
    echo "Usage: make_venv.sh PYTHON_MODULE"
    exit 1
fi

if [ -z $QUDA_PATH ]; then
    echo "Error: Lack of environment variable QUDA_PATH"
    exit 1
fi

DIR=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

pushd $HOME
module load ${MODULE}
PYTHON_VERSION=$(python3 -c 'from sys import version_info; print(f"{version_info[0]}{version_info[1]}")')
if !([ "${PYTHON_VERSION}" == "38" ] || [ "${PYTHON_VERSION}" == "39" ]); then
    echo "Error: Only Python 3.8 and 3.9 are supported"
    exit 1
fi
python3 -m venv .venv
module remove ${MODULE}
sed -i 's/include-system-site-packages = false/include-system-site-packages = true/' .venv/pyvenv.cfg
popd

source $HOME/.venv/bin/activate
pip install --no-build-isolation -v ${DIR}/Cython-0.29.37-cp${PYTHON_VERSION}-cp${PYTHON_VERSION}-manylinux_2_17_x86_64.manylinux2014_x86_64.manylinux_2_24_x86_64.whl
pip install --no-build-isolation -v ${DIR}/numpy-1.26.4-cp${PYTHON_VERSION}-cp${PYTHON_VERSION}-manylinux_2_17_x86_64.manylinux2014_x86_64.whl
pip install --no-build-isolation -v ${DIR}/fastrlock-0.8.3-cp${PYTHON_VERSION}-cp${PYTHON_VERSION}-manylinux_2_5_x86_64.manylinux1_x86_64.manylinux_2_28_x86_64.whl
pip install --no-build-isolation -v ${DIR}/opt_einsum-3.4.0-py3-none-any.whl
pip install --no-build-isolation -v ${DIR}/cupy-12.3.0.tar.gz
pip install --no-build-isolation -v ${DIR}/mpi4py-3.1.6.tar.gz
deactivate

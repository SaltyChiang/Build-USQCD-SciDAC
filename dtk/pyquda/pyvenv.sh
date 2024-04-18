#!/usr/bin/env bash

MODULE=apps/anaconda3/2022.10

QUDA_PATH=$1
if [ -z $QUDA_PATH ]; then
    echo "Error: Lack of parameters QUDA_PATH"
    echo "Usage: pyvenv.sh QUDA_PATH"
    exit 1
fi
export QUDA_PATH

DIR=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

pushd $HOME
module load ${MODULE}
PYVERSION=$(python3 -c 'from sys import version_info; print(f"{version_info[0]}{version_info[1]}")')
if !([ "${PYVERSION}" == "38" ] || [ "${PYVERSION}" == "39" ]); then
    echo "Error: Only Python 3.8 and 3.9 are supported"
    exit 1
fi
python3 -m venv .venv
module remove ${MODULE}
sed -i 's/include-system-site-packages = false/include-system-site-packages = true/' .venv/pyvenv.cfg
popd

source $HOME/.venv/bin/activate
pip install --no-build-isolation ${DIR}/mpi4py-3.1.5.tar.gz
pip install --no-build-isolation ${DIR}/fastrlock-0.8.2.tar.gz
pip install --no-build-isolation ${DIR}/numpy-1.24.4-cp${PYVERSION}-cp${PYVERSION}-manylinux_2_17_x86_64.manylinux2014_x86_64.whl
pip install --no-build-isolation ${DIR}/cupy-12.0.0b3-cp${PYVERSION}-cp${PYVERSION}-linux_x86_64.whl
pip install --no-build-isolation ${DIR}/opt_einsum-3.3.0-py3-none-any.whl
pip install --no-build-isolation ${DIR}/PyQUDA-0.6.15.tar.gz
deactivate

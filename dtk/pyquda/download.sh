#!/usr/bin/env bash

DIR=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
pushd ${DIR}

PYTHON_VERSION=$1

if [ -z $PYTHON_VERSION ]; then
    echo "Error: Lack of parameters PYTHON_VERSION"
    echo "Usage: download.sh PYTHON_VERSION"
    exit 1
fi

mkdir -p wheels
cd wheels
pip download --python-version $PYTHON_VERSION --only-binary=:all: "Cython==0.29.37"
pip download --python-version $PYTHON_VERSION --only-binary=:all: "numpy<2"
pip download --python-version $PYTHON_VERSION --only-binary=:all: "fastrlock==0.8.3"
pip download --no-deps "opt_einsum==3.4.0"
pip download --no-deps "cupy==12.3.0"
pip download --no-deps "mpi4py==3.1.6"
cd ..

mkdir -p venv
cp make_venv.sh venv
# tar -czf venv.tar.gz venv

popd

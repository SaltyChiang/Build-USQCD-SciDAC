#!/usr/bin/env bash

function git_checkout() {
    # git_checkout REPO URL BRANCH COMMIT
    if [ ! -d ${SRC}/$1 ]; then
        cd ${SRC}
        git clone --recursive $2 $1
        cd -
    fi
    if [ ! -d ${SRC}/$1 ]; then
        return 1
    fi
    echo "Enter ${SRC}/$1 (git_checkout)"
    cd ${SRC}/$1
    git reset
    git checkout .
    git checkout $3
    git pull
    git checkout $4
    git submodule update --recursive
    echo "Leave ${SRC}/$1 (git_checkout)"
    cd -
}

function git_apply() {
    # git_apply REPO
    if [ ! -d ${SRC}/$1 ]; then
        return 1
    fi
    echo "Enter ${SRC}/$1 (git_apply)"
    cd ${SRC}/$1
    git reset
    git checkout .
    git apply ${@:2}
    echo "Leave ${SRC}/$1 (git_apply)"
    cd -
}

function wget_sha256() {
    # wget_sha256 FILE URL SHA256
    if !([ -f ${SRC}/$1 ] && [ "$(sha256sum ${SRC}/$1 | awk '{print $1}')" == "$3" ]); then
        wget $2 -O ${SRC}/$1
    fi
}

mkdir -p ${SRC}

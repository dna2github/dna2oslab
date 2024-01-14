#/bin/bash
set -xe

MEDIR=$(cd `dirname $0`; pwd)
ME=openssl-3.2.0

cd $MEDIR
source env.sh

cd ..
rm -rf $ME
fetch_source $ME.tar.gz https://www.openssl.org/source/openssl-3.2.0.tar.gz
tar zxf $ENVSRCTARBALL/$ME.tar.gz
cd $ME
mkdir -p dist

export CROSS_COMPILE=""
./config -fPIC --prefix=$MEDIR/../$ME/dist/ no-asm

make
make_install $ME


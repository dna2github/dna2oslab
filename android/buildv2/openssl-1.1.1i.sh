#/bin/bash
set -xe

MEDIR=$(cd `dirname $0`; pwd)
ME=openssl-1.1.1i

cd $MEDIR
source env.sh

cd ..
rm -rf $ME
fetch_source $ME.tar.gz https://www.openssl.org/source/openssl-1.1.1i.tar.gz
tar zxf $ENVSRCTARBALL/$ME.tar.gz
cd $ME
mkdir -p dist

export CROSS_COMPILE=""
./config -fPIC --prefix=$MEDIR/../$ME/dist/ no-asm

make
make_install $ME


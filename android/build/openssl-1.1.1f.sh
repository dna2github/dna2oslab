#/bin/bash
set -xe

MEDIR=$(cd `dirname $0`; pwd)
ME=openssl-1.1.1f

cd $MEDIR
source env.sh
source common.sh

cd ..
rm -rf $ME
fetch_source $ME.tar.gz https://www.openssl.org/source/openssl-1.1.1f.tar.gz
tar zxf $SRCTARBALL/$ME.tar.gz
cd $ME
mkdir -p dist

./config -fPIC --prefix=$MEDIR/../$ME/dist/ no-asm

sed -i "s|-Wall|-Wall --sysroot=$ANDROID|" Makefile

make
make_install $ME


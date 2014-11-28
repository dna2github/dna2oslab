#/bin/bash
set -xe

MEDIR=$(cd `dirname $0`; pwd)
ME=sqlite-autoconf-3080701

cd $MEDIR
source common.sh

cd ..
rm -rf $ME
tar zxf $SRCTARBALL/$ME.tar.gz
cd $ME
mkdir -p dist

./configure --host=arm-linux --build=x86_64-linux \
            --with-sysroot=$ANDROID --prefix=$MEDIR/../$ME/dist

make
make_install $ME


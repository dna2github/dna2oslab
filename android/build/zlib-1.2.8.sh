#/bin/bash
set -xe

MEDIR=$(cd `dirname $0`; pwd)
ME=zlib-1.2.8

cd $MEDIR
source common.sh

cd ..
rm -rf $ME
tar zxf $SRCTARBALL/$ME.tar.gz
cd $ME
mkdir -p dist

sed -i "s|z_const|const|" test/example.c

./configure --static --prefix=$MEDIR/../$ME/dist

export CFLAGS="$CFLAGS -fPIC"
make
make_install $ME


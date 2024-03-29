#/bin/bash
set -xe

MEDIR=$(cd `dirname $0`; pwd)
ME=zlib-1.3

cd $MEDIR
source env.sh

cd ..
rm -rf $ME
fetch_source $ME.tar.gz http://zlib.net/$ME.tar.gz
tar zxf $ENVSRCTARBALL/$ME.tar.gz
cd $ME
mkdir -p dist

sed -i "s|z_const|const|" test/example.c

./configure --static --prefix=$MEDIR/../$ME/dist

export CFLAGS="$CFLAGS -fPIC"
make
make_install $ME


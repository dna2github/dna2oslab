#/bin/bash
set -xe

MEDIR=$(cd `dirname $0`; pwd)
ME=sqlite-autoconf-3340100

cd $MEDIR
source env.sh

cd ..
rm -rf $ME
fetch_source $ME.tar.gz https://www.sqlite.org/2021/sqlite-autoconf-3340100.tar.gz
tar zxf $ENVSRCTARBALL/$ME.tar.gz
cd $ME
mkdir -p dist

./configure $CROSS_COMPILE \
            --with-sysroot=$ANDROID --prefix=$MEDIR/../$ME/dist

make
make_install $ME


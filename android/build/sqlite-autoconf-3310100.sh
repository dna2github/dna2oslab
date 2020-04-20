#/bin/bash
set -xe

MEDIR=$(cd `dirname $0`; pwd)
ME=sqlite-autoconf-3310100

cd $MEDIR
source env.sh
source common.sh

cd ..
rm -rf $ME
fetch_source $ME.tar.gz https://www.sqlite.org/2020/sqlite-autoconf-3310100.tar.gz
tar zxf $SRCTARBALL/$ME.tar.gz
cd $ME
mkdir -p dist

./configure --host=arm-linux --build=x86_64-linux \
            --with-sysroot=$ANDROID --prefix=$MEDIR/../$ME/dist

make
make_install $ME


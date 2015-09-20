#/bin/bash
set -xe

MEDIR=$(cd `dirname $0`; pwd)
ME=pcre-8.37

cd $MEDIR
source common.sh

cd ..
rm -rf $ME
tar zxf $SRCTARBALL/$ME.tar.gz
cd $ME
mkdir -p dist

#sed -i "s/^mkfifo/_mkfifo/" gnu/mkfifo.c

export CFLAGS="$CFLAGS $CXXCONFIGFLAGS $CXXLIBPLUS"
export CXXFLAGS="$CXXFLAGS $CXXCONFIGFLAGS $CXXLIBPLUS -lgnustl_shared -lgnustl_static -lsupc++"
export LDFLAGS="$LDFLAGS $CXXLIBPLUS -lgnustl_shared -lgnustl_static -lsupc++"

./configure $CONFIGFLAGS --prefix=$MEDIR/../$ME/dist/

make
make_install $ME


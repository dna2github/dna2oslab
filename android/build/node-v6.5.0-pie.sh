#/bin/bash

set -xe

MEDIR=$(cd `dirname $0`; pwd)
ME=node-v6.5.0

cd $MEDIR
source common.sh

cd ..
rm -rf $ME
tar zxf $SRCTARBALL/$ME.tar.gz
cd $ME
mkdir -p dist out

cp $NDKDIR/sources/cxx-stl/gnu-libstdc++/4.9/libs/armeabi/lib* out/
cp $ANDROID/lib/* out/
sed -i "s|historyPath = path.join.*|historyPath = '/data/local/tmp/.node_repl_history';|" $MEDIR/../$ME/lib/internal/repl.js
sed -i "s/uv__getiovmax()/1024/" $MEDIR/../$ME/deps/uv/src/unix/fs.c
sed -i "s/uv__getiovmax()/1024/" $MEDIR/../$ME/deps/uv/src/unix/stream.c
sed -i "s/UV__POLLIN/1/g" $MEDIR/../$ME/deps/uv/src/unix/core.c
sed -i "s/UV__POLLOUT/4/g" $MEDIR/../$ME/deps/uv/src/unix/core.c

export CFLAGS="$CFLAGS $CXXCONFIGFLAGS $CXXLIBPLUS"
export CXXFLAGS="$CXXFLAGS $CXXCONFIGFLAGS $CXXLIBPLUS"
export LDFLAGS="$LDFLAGS $CXXLIBPLUS"
export CPPFLAGS_host=$CXXFLAGS
export CPPFLAGS=$CXXFLAGS
export CFLAGS_host=$CFLAGS

./configure --prefix=$MEDIR/../$ME/dist/ --without-snapshot --dest-cpu=arm --dest-os=android --with-intl=none
sed -i '' "s|LIBS := \\\\|LIBS := -lgnustl_static\\\\|" $MEDIR/../$ME/out/node.target.mk
sed -i '' "s|include cctest.target.mk|#include cctest.target.mk|" $MEDIR/../$ME/out/Makefile

make
make_install $ME


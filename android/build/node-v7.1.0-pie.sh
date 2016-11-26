#/bin/bash

set -xe

MEDIR=$(cd `dirname $0`; pwd)
ME=node-v7.1.0

cd $MEDIR
source common.sh

cd ..
rm -rf $ME
fetch_source $SRCTARBALL/$ME.tar.gz https://nodejs.org/dist/v7.1.0/node-v7.1.0.tar.gz
tar zxf $SRCTARBALL/$ME.tar.gz
cd $ME
mkdir -p dist out

cp $NDKDIR/sources/cxx-stl/gnu-libstdc++/${GCC_VERSION}/libs/armeabi/lib* out/
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
sed -i "s|LIBS := \\\\|LIBS := -lgnustl_static\\\\|" $MEDIR/../$ME/out/node.target.mk
sed -i "s|LIBS := \\\\|LIBS := -lgnustl_static\\\\|" $MEDIR/../$ME/out/deps/v8/src/mkpeephole.target.mk
# skip generate bytecode-peephole-table.cc
# get no difference; diff -Nur bytecode-peephole-table.cc(mkpeephole on mac) bytecode-peephole-table.cc(mkpeephole on android)
sed -i 's|"$(builddir)/mkpeephole"|echo|' $MEDIR/../$ME/out/deps/v8/src/v8_base.target.mk
cp $MEDIR/node_v8base_geni_bytecode-peephole-table.cc out/Release/obj.target/v8_base/geni/bytecode-peephole-table.cc
# skip cctest; if want, you may need to add -lgnustl_static to cctest.target.mk
sed -i "s|include cctest.target.mk|#include cctest.target.mk|" $MEDIR/../$ME/out/Makefile # skip cctest

make
# if want generate bytecode-peephole-table.cc manually, pls adb push this binary to your android
# run `./v8_mkpeephole bytecode-peephole-table.cc; replace node_v8base_geni_bytecode-peephole-table.cc with yours`
cp out/Release/mkpeephole $MEDIR/../$ME/dist/bin/v8_mkpeephole

make_install $ME


#/bin/bash
set -xe

MEDIR=$(cd `dirname $0`; pwd)
ME=node-v0.12.6

cd $MEDIR
source env.sh
source common.sh

cd ..
rm -rf $ME
fetch_source $ME.tar.gz https://nodejs.org/dist/v0.12.6/node-v0.12.6.tar.gz
tar zxf $SRCTARBALL/$ME.tar.gz
cd $ME
mkdir -p dist out

cp $NDKDIR/sources/cxx-stl/gnu-libstdc++/${GCC_VERSION}/libs/armeabi/lib* out/
cp $ANDROID/lib/* out/
cp $MEDIR/node_deps_uv_src_unix_core.c $MEDIR/../$ME/deps/uv/src/unix/core.c

export CFLAGS="$CFLAGS $CXXCONFIGFLAGS $CXXLIBPLUS"
export CXXFLAGS="$CXXFLAGS $CXXCONFIGFLAGS $CXXLIBPLUS -lgnustl_shared -lgnustl_static -lsupc++"
export LDFLAGS="$LDFLAGS $CXXLIBPLUS -lgnustl_shared -lgnustl_static -lsupc++"

./configure --prefix=$MEDIR/../$ME/dist/ --without-snapshot --dest-cpu=arm --dest-os=android

make
make_install $ME


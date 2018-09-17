#/bin/bash

set -xe

MEDIR=$(cd `dirname $0`; pwd)
ME=node-v8.12.0

cd $MEDIR
source env.sh
source common.sh

cd ..
rm -rf $ME
fetch_source $ME.tar.gz https://nodejs.org/dist/v8.12.0/node-v8.12.0.tar.gz
tar zxf $SRCTARBALL/$ME.tar.gz
cd $ME
mkdir -p dist out

cp $LIBCXX/lib*.a out/
#cp $CXXPLUS/libs/armeabi/libgnustl_static.a out/
cp $ANDROID/lib/* out/
sed -i "s|historyPath = path.join.*|historyPath = '/data/local/tmp/.node_repl_history';|" $MEDIR/../$ME/lib/internal/repl.js
sed -i "s/uv__getiovmax()/1024/" $MEDIR/../$ME/deps/uv/src/unix/fs.c
sed -i "s/uv__getiovmax()/1024/" $MEDIR/../$ME/deps/uv/src/unix/stream.c
sed -i "s/UV__POLLIN/1/g" $MEDIR/../$ME/deps/uv/src/unix/core.c
sed -i "s/UV__POLLOUT/4/g" $MEDIR/../$ME/deps/uv/src/unix/core.c

# see # see https://github.com/nodejs/node/issues/3074
sed -i 's/#define HAVE_GETSERVBYPORT_R 1/#undef HAVE_GETSERVBYPORT_R/' deps/cares/config/android/ares_config.h 

export CC="$CC --sysroot=$ANDROID -I$ANDROID/include -L$ANDROID/lib"
export CXX="$CXX --sysroot=$ANDROID -I$ANDROID/include -I$NDKDIR/sources/android/support/include -L$ANDROID/lib -L$MEDIR/../$ME/out"
export CFLAGS="$CFLAGS $LIBCXXFLAGS $PIEFLAG"
export CXXFLAGS="$CXXFLAGS $LIBCXXFLAGS $PIEFLAG"
export LDFLAGS="$LDFLAGS $PIEFLAG -L$MEDIR/../$ME/out"
export CPPFLAGS_host=$CXXFLAGS
export CPPFLAGS=$CXXFLAGS
export CFLAGS_host=$CFLAGS

# copy from android-configure.sh and set $(ARCH)=arm
GYP_DEFINES="target_arch=arm"
GYP_DEFINES+=" v8_target_arch=arm"
GYP_DEFINES+=" android_target_arch=arm"
GYP_DEFINES+=" host_os=linux OS=android"
export GYP_DEFINES

./configure --prefix=$MEDIR/../$ME/dist/ --without-snapshot --dest-cpu=arm --dest-os=android --with-intl=none

sed -i "s|-lm|-lc++_static -lc++ -lm|" $MEDIR/../$ME/out/node.target.mk
# skip cctest; if want, you may need to add -lgnustl_static to cctest.target.mk
sed -i "s|include cctest.target.mk|#include cctest.target.mk|" $MEDIR/../$ME/out/Makefile # skip cctest
sed -i "s|include deps/gtest/gtest.target.mk|#include deps/gtest/gtest.target.mk|" $MEDIR/../$ME/out/Makefile # skip gtest

make
make_install $ME


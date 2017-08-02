#/bin/bash

set -xe

MEDIR=$(cd `dirname $0`; pwd)
ME=node-v4.4.4

cd $MEDIR
source env.sh
source common.sh

cd ..
rm -rf $ME
fetch_source $ME.tar.gz https://nodejs.org/dist/v4.4.4/node-v4.4.4.tar.gz
tar zxf $SRCTARBALL/$ME.tar.gz
cd $ME
mkdir -p dist out

cp $NDKDIR/sources/cxx-stl/gnu-libstdc++/${GCC_VERSION}/libs/armeabi/lib* out/
cp $ANDROID/lib/* out/
sed -i "s|historyPath = path.join.*|historyPath = '/data/local/tmp/.node_repl_history';|" $MEDIR/../$ME/lib/internal/repl.js
sed -i "s/uv__getiovmax()/1024/" $MEDIR/../$ME/deps/uv/src/unix/fs.c
sed -i "s/uv__getiovmax()/1024/" $MEDIR/../$ME/deps/uv/src/unix/stream.c
sed -i "s/path.join(os.homedir(), '.node_repl_history');/'\/data\/local\/tmp\/.node_repl_history';/" $MEDIR/../$ME/lib/internal/repl.js

export CFLAGS="$CFLAGS $CXXCONFIGFLAGS $CXXLIBPLUS $PIEFLAG"
export CXXFLAGS="$CXXFLAGS $CXXCONFIGFLAGS $CXXLIBPLUS -lgnustl_shared -lgnustl_static -lsupc++ $PIEFLAG"
export LDFLAGS="$LDFLAGS $CXXLIBPLUS -lgnustl_shared -lgnustl_static -lsupc++ $PIEFLAG"

./configure --prefix=$MEDIR/../$ME/dist/ --without-snapshot --dest-cpu=arm --dest-os=android

make
make_install $ME


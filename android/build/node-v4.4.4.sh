#/bin/bash

echo "===================================================================="
echo "Notice: if it throws error and report something wrong"
echo "about '.node_repl_history' to run ./node, please open"
echo "'lib/internal/repl.js' under source code directory,"
echo "find this line:"
echo "   historyPath = path.join(os.homedir(), '.node_repl_history');"
echo " and fix the path like:"
echo "   historyPath = '/data/local/tmp/.node_repl_history';"
echo " then rebuild nodejs."
echo "===================================================================="
sleep 2

set -xe

MEDIR=$(cd `dirname $0`; pwd)
ME=node-v4.4.4

cd $MEDIR
source env.sh
source common.sh

cd ..
rm -rf $ME
fetch_source $SRCTARBALL/$ME.tar.gz https://nodejs.org/dist/v4.4.4/node-v4.4.4.tar.gz
tar zxf $SRCTARBALL/$ME.tar.gz
cd $ME
mkdir -p dist out

cp $NDKDIR/sources/cxx-stl/gnu-libstdc++/${GCC_VERSION}/libs/armeabi/lib* out/
cp $ANDROID/lib/* out/
sed -i "s/uv__getiovmax()/1024/" $MEDIR/../$ME/deps/uv/src/unix/fs.c
sed -i "s/uv__getiovmax()/1024/" $MEDIR/../$ME/deps/uv/src/unix/stream.c
sed -i "s/path.join(os.homedir(), '.node_repl_history');/'\/data\/local\/tmp\/.node_repl_history';/" $MEDIR/../$ME/lib/internal/repl.js

export CFLAGS="$CFLAGS $CXXCONFIGFLAGS $CXXLIBPLUS"
export CXXFLAGS="$CXXFLAGS $CXXCONFIGFLAGS $CXXLIBPLUS -lgnustl_shared -lgnustl_static -lsupc++"
export LDFLAGS="$LDFLAGS $CXXLIBPLUS -lgnustl_shared -lgnustl_static -lsupc++"

./configure --prefix=$MEDIR/../$ME/dist/ --without-snapshot --dest-cpu=arm --dest-os=android

make
make_install $ME

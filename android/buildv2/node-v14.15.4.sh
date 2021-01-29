#/bin/bash
set -xe

MEDIR=$(cd `dirname $0`; pwd)
ME=node-v14.15.4

cd $MEDIR
source env.sh

cd ..
rm -rf $ME
fetch_source $ME.tar.gz https://nodejs.org/dist/v14.15.4/node-v14.15.4.tar.gz
tar zxf $ENVSRCTARBALL/$ME.tar.gz
cd $ME

# by default, build for arm64
ARCH=arm64
DEST_CPU=arm64
HOST_OS="linux"
HOST_ARCH="x86_64"

if [ "$HOST_GCC_DIR" == "" ]; then
if [ ! -d $MEDIR/local/gcc-9.3.0 ]; then
   cat <<EOF
it will start to compile gcc-9.3.0;
if you have any (gcc >= 6.3), please stop the script and
   - set CC_host, CXX_host, AR_host, RANLIB_host
   - or set HOST_GCC_DIR to the specified GCC root directory
EOF
   sleep 10
   # build gcc-9.3.0
   bash host_gcc_9.3.sh
   HOST_GCC_DIR=$MEDIR/local/gcc-9.3.0/dist
fi
fi

echo host gcc: $HOST_GCC_DIR

export CC_host=$HOST_GCC_DIR/bin/gcc
export CXX_host=$HOST_GCC_DIR/bin/g++
export AR_host=$HOST_GCC_DIR/bin/gcc-ar
export RANLIB_host=$HOST_GCC_DIR/bin/gcc-ranlib
export LD_LIBRARY_PATH=$HOST_GCC_DIR/lib64:$LD_LIBRARY_PATH

GYP_DEFINES="target_arch=$ARCH"
GYP_DEFINES+=" v8_target_arch=$ARCH"
GYP_DEFINES+=" android_target_arch=$ARCH"
GYP_DEFINES+=" host_os=$HOST_OS OS=android"
export GYP_DEFINES

./configure \
    --prefix=$MEDIR/../dist/$ME \
    --dest-cpu=$DEST_CPU \
    --dest-os=android \
    --without-snapshot \
    --openssl-no-asm \
    --cross-compiling

grep "LD_LIBRARY_PATH=" . -r | grep -v Binary | cut -d ':' -f 1 | sort -u | xargs sed -i "s|LD_LIBRARY_PATH=|LD_LIBRARY_PATH=$HOST_GCC_DIR/dist/lib64:|g"

make -j4
make install

cd ..
rm -rf $ME

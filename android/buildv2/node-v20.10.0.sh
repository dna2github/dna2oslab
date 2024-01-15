#/bin/bash
set -xe

MEDIR=$(cd `dirname $0`; pwd)
ME=node-v20.10.0

cd $MEDIR
source env.sh

cd ..
rm -rf $ME
fetch_source $ME.tar.gz https://nodejs.org/dist/v20.10.0/node-v20.10.0.tar.gz
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

# XXX why android-configure not work? it assume you build in the same arch ...
#sed -i 's|#define HAVE_EXECINFO_H 1||' deps/v8/src/base/debug/stack_trace_posix.cc
#sed -i "s|configure --dest-cpu=|configure --prefix=$MEDIR/../dist/$ME --dest-cpu=|" android_configure.py
#./android-configure $NDK $ENVANDROIDVER arm64
#make -j4
#make install
#exit 0

GYP_DEFINES="target_arch=$ARCH"
GYP_DEFINES+=" v8_target_arch=$ARCH"
GYP_DEFINES+=" android_target_arch=$ARCH"
GYP_DEFINES+=" host_os=$HOST_OS OS=android"
GYP_DEFINES+=" android_ndk_path=$NDK"
export GYP_DEFINES

# although arm64 enabled this feature, if cross-compile from x86_64 platform,
# it will report unrecognized command line option for host gcc
# TODO need to take time to list all host gcc target and remove -msign-return-address in future
sed -i 's|.*-msign-return-address=all.*||' ./configure.py


./configure \
    --prefix=$MEDIR/../dist/$ME \
    --dest-cpu=$DEST_CPU \
    --dest-os=android \
    --without-snapshot \
    --openssl-no-asm \
    --cross-compiling

grep "LD_LIBRARY_PATH=" . -r | grep -v Binary | cut -d ':' -f 1 | sort -u | xargs sed -i "s|LD_LIBRARY_PATH=|LD_LIBRARY_PATH=$HOST_GCC_DIR/dist/lib64:|g"

# make sure some functions are available in link stage
#sed -i 's|/poll.o \\|/poll.o \\\n\t$(obj).target/$(TARGET)/deps/uv/src/unix/epoll.o \\|' out/deps/uv/libuv.target.mk

# disable TRAP_HANDLER
sed -i "s|// Setup for shared library export.|#undef V8_TRAP_HANDLER_VIA_SIMULATOR\n#undef V8_TRAP_HANDLER_SUPPORTED\n#define V8_TRAP_HANDLER_SUPPORTED false\n\n// Setup for shared library export.|" deps/v8/src/trap-handler/trap-handler.h

# it is weird that the cpu-features.o not compiled even zlib compiled with this feature
# change to your target arch  -D__x86_64__ -D__arm__ -D__i386__
$CC -D__aarch64__ -c -o out/cpu-features.o $NDK/sources/android/cpufeatures/cpu-features.c
sed -i 's|$(obj)[.]target/deps/zlib/libzlib[.]a|$(obj).target/../../cpu-features.o $(obj).target/deps/zlib/libzlib.a|g' ./out/embedtest.target.mk
sed -i 's|$(obj)[.]target/deps/zlib/libzlib[.]a|$(obj).target/../../cpu-features.o $(obj).target/deps/zlib/libzlib.a|g' ./out/cctest.target.mk
sed -i 's|$(obj)[.]target/deps/zlib/libzlib[.]a|$(obj).target/../../cpu-features.o $(obj).target/deps/zlib/libzlib.a|g' ./out/node.target.mk
sed -i 's|$(obj)[.]target/deps/zlib/libzlib[.]a|$(obj).target/../../cpu-features.o $(obj).target/deps/zlib/libzlib.a|g' ./out/node_mksnapshot.target.mk

make -j4
make install

cd ..
rm -rf $ME

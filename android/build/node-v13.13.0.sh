#/bin/bash
set -xe

MEDIR=$(cd `dirname $0`; pwd)
ME=node-v13.13.0

cd $MEDIR
source env.sh
source common.sh

cd ..
rm -rf $ME
fetch_source $ME.tar.gz https://nodejs.org/dist/v13.13.0/node-v13.13.0.tar.gz
tar zxf $SRCTARBALL/$ME.tar.gz
cd $ME

# by default, build for arm64
ARCH=arm64
DEST_CPU=arm64
HOST_OS="linux"
HOST_ARCH="x86_64"

cat <<EOF
it will start to compile gcc-9.3.0;
if you have any (gcc >= 6.3), please stop the script and set CC_host, CXX_host, AR_host, RANLIB_host
EOF
sleep 10
if [ ! -d $MEDIR/local/gcc-9.3.0 ]; then
   # build gcc-9.3.0
   bash host_gcc_9.3.sh
fi

export CC_host=$MEDIR/local/gcc-9.3.0/dist/bin/gcc
export CXX_host=$MEDIR/local/gcc-9.3.0/dist/bin/g++
export AR_host=$MEDIR/local/gcc-9.3.0/dist/bin/gcc-ar
export RANLIB_host=$MEDIR/local/gcc-9.3.0/dist/bin/gcc-ranlib
export LD_LIBRARY_PATH=$MEDIR/local/gcc-9.3.0/dist/lib64:$LD_LIBRARY_PATH

GYP_DEFINES="target_arch=$ARCH"
GYP_DEFINES+=" v8_target_arch=$ARCH"
GYP_DEFINES+=" android_target_arch=$ARCH"
GYP_DEFINES+=" host_os=$HOST_OS OS=android"
export GYP_DEFINES

./configure \
    --prefix=$MEDIR/../$DISTBIN/$ME \
    --dest-cpu=$DEST_CPU \
    --dest-os=android \
    --without-snapshot \
    --openssl-no-asm \
    --cross-compiling --prefix=$MEDIR/../bin/node-v13.13.0

grep "LD_LIBRARY_PATH=" . -r | grep -v Binary | cut -d ':' -f 1 | sort -u | xargs sed -i "s|LD_LIBRARY_PATH=|LD_LIBRARY_PATH=$MEDIR/local/gcc-9.3.0/dist/lib64:|g"

awk "NR < 41" deps/uvwasi/src/uvwasi.c > .shit_patch
cat >> .shit_patch <<EOF

// shit patch
// https://kernel.googlesource.com/pub/scm/fs/ext2/xfstests-bld/+/HEAD/android-compat/telldir.c
struct DIR {
  int fd_;
};
long telldir(struct DIR *dirp)
{
	return (long) lseek(dirp->fd_, 0, SEEK_CUR);
}
void seekdir(DIR *dirp, long loc)
{
	(void) lseek(dirp->fd_, loc, SEEK_SET);
}
EOF
awk "NR >= 41" deps/uvwasi/src/uvwasi.c >> .shit_patch
cp deps/uvwasi/src/uvwasi.c .shit_backup
cp .shit_patch deps/uvwasi/src/uvwasi.c

make -j4
# resolve '__emutls_get_address' missing, adding $SELF/local/toolchain/lib/gcc/aarch64-linux-android/4.9.x/libgcc_real.a
# not sure what you are using, i am using ndk-r21 ...; but please `grep "__emutls_get_address" $SELF/local/toolchain` and find a possible .a lib for node
# NODED=`find out -name node.d`
# sed -i "s|-rdynamic||" $NODED
# sed -i "s|libv8_initializers.a|libv8_initializers.a $SELF/local/toolchain/lib/gcc/aarch64-linux-android/4.9.x/libgcc_real.a|" $NODED
# make -j4

make install

$CXX -Wl,--whole-archive $MEDIR/../$ME/out/Release/obj.target/libnode.a $MEDIR/../$ME/out/Release/obj.target/tools/v8_gypfiles/libv8_base_without_compiler.a -Wl,--no-whole-archive -Wl,--whole-archive $MEDIR/../$ME/out/Release/obj.target/deps/zlib/libzlib.a -Wl,--no-whole-archive -Wl,--whole-archive $MEDIR/../$ME/out/Release/obj.target/deps/uv/libuv.a -Wl,--no-whole-archive -fPIC  -o $MEDIR/../$ME/out/Release/node -Wl,--start-group $MEDIR/../$ME/out/Release/obj.target/node/src/node_main.o $MEDIR/../$ME/out/Release/obj.target/node/src/node_code_cache_stub.o $MEDIR/../$ME/out/Release/obj.target/node/src/node_snapshot_stub.o $MEDIR/../$ME/out/Release/obj.target/deps/histogram/libhistogram.a $MEDIR/../$ME/out/Release/obj.target/deps/uvwasi/libuvwasi.a $MEDIR/../$ME/out/Release/obj.target/libnode.a $MEDIR/../$ME/out/Release/obj.target/tools/v8_gypfiles/libv8_libplatform.a $MEDIR/../$ME/out/Release/obj.target/tools/icu/libicui18n.a $MEDIR/../$ME/out/Release/obj.target/deps/zlib/libzlib.a $MEDIR/../$ME/out/Release/obj.target/deps/llhttp/libllhttp.a $MEDIR/../$ME/out/Release/obj.target/deps/cares/libcares.a $MEDIR/../$ME/out/Release/obj.target/deps/uv/libuv.a $MEDIR/../$ME/out/Release/obj.target/deps/nghttp2/libnghttp2.a $MEDIR/../$ME/out/Release/obj.target/deps/brotli/libbrotli.a $MEDIR/../$ME/out/Release/obj.target/deps/openssl/libopenssl.a $MEDIR/../$ME/out/Release/obj.target/tools/v8_gypfiles/libv8_base_without_compiler.a $MEDIR/../$ME/out/Release/obj.target/tools/icu/libicuucx.a $MEDIR/../$ME/out/Release/obj.target/tools/icu/libicudata.a $MEDIR/../$ME/out/Release/obj.target/tools/v8_gypfiles/libv8_libbase.a $MEDIR/../$ME/out/Release/obj.target/tools/v8_gypfiles/libv8_libsampler.a $MEDIR/../$ME/out/Release/obj.target/tools/v8_gypfiles/libv8_compiler.a $MEDIR/../$ME/out/Release/obj.target/tools/v8_gypfiles/libv8_snapshot.a $MEDIR/../$ME/out/Release/obj.target/tools/v8_gypfiles/libv8_initializers.a $SELF/local/toolchain/lib/gcc/aarch64-linux-android/4.9.x/libgcc_real.a -Wl,--end-group -lm -ldl -llog
$STRIP out/Release/node
cp out/Release/node $MEDIR/../bin/node-v13.13.0/bin/node

cd ..
rm -rf $ME

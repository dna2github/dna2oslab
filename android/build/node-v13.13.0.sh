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
sed -i "s|libv8_initializers.a|libv8_initializers.a $SELF/local/toolchain/lib/gcc/aarch64-linux-android/4.9.x/libgcc_real.a|" `find out -name node.d`
make -j4

make_install $ME


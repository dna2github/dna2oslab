#/bin/bash
set -xe

MEDIR=$(cd `dirname $0`; pwd)

ME="binutils-2.24"

cd $MEDIR
source common.sh
export AR="$COMPILER/arm-linux-androideabi-ar"
export AS="$COMPILER/arm-linux-androideabi-as"
export LD="$COMPILER/arm-linux-androideabi-ld"
export NM="$COMPILER/arm-linux-androideabi-nm"
export RANLIB="$COMPILER/arm-linux-androideabi-ranlib"
export STRIP="$COMPILER/arm-linux-androideabi-strip"
export OBJCOPY="$COMPILER/arm-linux-androideabi-objcopy"
export OBJDUMP="$COMPILER/arm-linux-androideabi-objdump"
export READELF="$COMPILER/arm-linux-androideabi-readelf"
export CFLAGS="-I$MEDIR/../$ME/include $CFLAGS"

cd ..
rm -rf $ME
fetch_source $ME.tar.gz http://ftp.gnu.org/gnu/binutils/binutils-2.24.tar.gz
tar zxf $SRCTARBALL/$ME.tar.gz
cd $ME
mkdir -p dist

./configure $CONFIGFLAGS --disable-werror --disable-nls --prefix="$MEDIR/../$ME/dist/"

cp include/sha1.h libiberty/
sed -i "s/getpagesize/_getpagesize/" libiberty/getpagesize.c

make
make_install $ME

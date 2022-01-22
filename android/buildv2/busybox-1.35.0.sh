#/bin/bash
set -xe

MEDIR=$(cd `dirname $0`; pwd)
ME=busybox-1.35.0

cd $MEDIR
source env.sh

cd ..
rm -rf $ME
fetch_source ${ME}.tar.bz2 https://busybox.net/downloads/${ME}.tar.bz2
tar jxf $ENVSRCTARBALL/$ME.tar.bz2
cd $ME
mkdir -p dist

unset CROSS_COMPILE
export KBUILD_VERBOSE=1

sed -i "s|^AS.*=.*as$|AS = ${AS}|" Makefile
sed -i "s|^CC.*=.*gcc$|CC = ${CC}|" Makefile
sed -i "s|^AR.*=.*ar$|AR = ${AR}|" Makefile
sed -i "s|^NM.*=.*nm$|NM = ${NM}|" Makefile
sed -i "s|^STRIP.*=.*strip$|STRIP = ${STRIP}|" Makefile
sed -i "s|^OBJCOPY.*=.*objcopy$|OBJCOPY = ${OBJCOPY}|" Makefile
sed -i "s|^OBJDUMP.*=.*objdump$|OBJDUMP = ${OBJDUMP}|" Makefile

sed -i "s|CONFIG_EXTRA_CFLAGS=.*|CONFIG_EXTRA_CFLAGS=-DANDROID -D__ANDROID__ -DSK_RELEASE -fpic|" configs/android_ndk_defconfig
sed -i "s|CONFIG_EXTRA_LDFLAGS=.*|CONFIG_EXTRA_LDFLAGS=|" configs/android_ndk_defconfig
sed -i "s|CONFIG_SYSROOT=.*|CONFIG_SYSROOT=${ANDROID}|" configs/android_ndk_defconfig
make android_ndk_defconfig
sed -i 's|^char\* FAST_FUNC strchrnul(|char* FAST_FUNC strchrnul_not_used(|' libbb/platform.c
LDFLAGS="-static" make -j 4

TARGET=${MEDIR}/../${ENVDISTBIN}/${ME}
rm -rf ${TARGET}
mkdir -p ${TARGET}/sbin
cp busybox ${TARGET}/sbin/
cd ..
rm -rf ${ME}

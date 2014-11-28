#/bin/bash
set -xe

MEDIR=$(cd `dirname $0`; pwd)
ME=openssl-1.0.1j

cd $MEDIR

source common.sh
cd ..
rm -rf $ME
tar zxf $SRCTARBALL/$ME.tar.gz
cd $ME
mkdir -p dist

MACHINE=armv7 SYSTEM=android ./config -fPIC --prefix=$MEDIR/../$ME/dist/

sed -i "s|-m64||" Makefile
sed -i "s|-Wall|-Wall --sysroot=$ANDROID|" Makefile

make
make_install $ME


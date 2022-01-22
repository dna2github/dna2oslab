#/bin/bash
set -xe

MEDIR=$(cd `dirname $0`; pwd)
ME=musl-1.2.2

cd $MEDIR
source env.sh

cd ..
rm -rf $ME
fetch_source $ME.tar.gz https://musl.libc.org/releases/musl-1.2.2.tar.gz
tar zxf $ENVSRCTARBALL/$ME.tar.gz
cd $ME
mkdir -p dist

# disable long double check
sed -i 's|long double|double|g' configure

./configure --prefix=$MEDIR/../$ME/dist/ $CROSS_COMPILE

# if we directly use --target=aarch64,
# long double check always fails, whatever we change it to double or float
# so change arm to aarch64 here
sed -i 's|ARCH = arm|ARCH = aarch64|' config.mak

make
make_install $ME

echo 'It is experimental build; not tested for further usage ...'

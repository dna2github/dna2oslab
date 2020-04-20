#/bin/bash
set -xe

MEDIR=$(cd `dirname $0`; pwd)
ME=node-v0.12.6

cd $MEDIR
source env.sh
source common.sh

cd ..
rm -rf $ME
fetch_source $ME.tar.gz https://nodejs.org/dist/v0.12.6/node-v0.12.6.tar.gz
tar zxf $SRCTARBALL/$ME.tar.gz
cd $ME

export PATH=$COMPILER:$PATH

LDFLAGS="-static" ./configure --prefix=$MEDIR/../$ME/dist/ --without-snapshot --dest-cpu=arm --dest-os=android --openssl-no-asm

sed -i 's|static internal::Object\*\* CreateHandle(|public: static internal::Object** CreateHandle(|g' deps/v8/include/v8.h
sed -i 's|zone_allocator<std::pair<int, Constant> > > ConstantMap|zone_allocator<std::pair<const int, Constant> > > ConstantMap|g' deps/v8/src/compiler/instruction.h

make
make_install $ME


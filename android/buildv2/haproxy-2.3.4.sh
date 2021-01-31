#/bin/bash
set -xe

MEDIR=$(cd `dirname $0`; pwd)
ME=haproxy-2.3.4

cd $MEDIR
source env.sh

cd ..
rm -rf $ME
fetch_source $ME.tar.gz http://www.haproxy.org/download/2.3/src/haproxy-2.3.4.tar.gz
tar zxf $ENVSRCTARBALL/$ME.tar.gz
cd $ME
mkdir -p dist

sed -i "s|^PREFIX = .*$|PREFIX = $MEDIR/../$ME/dist|" Makefile

make TARGET=generic PREFIX=$MEDIR/../$ME/dist CC="$CC --sysroot=$ANDROID -I$ANDROID/include -L$ANDROID/lib"
make_install $ME

#/bin/bash
set -xe

MEDIR=$(cd `dirname $0`; pwd)
ME=tcptunnel-0.8

cd $MEDIR
source env.sh

cd ..
rm -rf $ME
fetch_source $ME.tar.gz https://github.com/vakuum/tcptunnel/archive/v0.8.tar.gz
tar zxf $ENVSRCTARBALL/$ME.tar.gz
cd $ME

sed -i "s|unsigned int client_addr_size|socklen_t client_addr_size|" src/tcptunnel.c
$CC -Wall -Isrc -I$ANDROID/include -L$ANDROID/lib --sysroot=$ANDROID -o tcptunnel src/tcptunnel.c

rm -rf ../$ENVDISTBIN/$ME
mkdir -p ../$ENVDISTBIN/$ME/$ENVDISTBIN
cp tcptunnel ../$ENVDISTBIN/$ME/$ENVDISTBIN
cd ..
rm -rf $ME

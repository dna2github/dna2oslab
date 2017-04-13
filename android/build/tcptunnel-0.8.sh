#/bin/bash
set -xe

MEDIR=$(cd `dirname $0`; pwd)
ME=tcptunnel-0.8

cd $MEDIR
source env.sh
source common.sh

cd ..
rm -rf $ME
fetch_source $ME.tar.gz https://github.com/vakuum/tcptunnel/archive/v0.8.tar.gz
tar zxf $SRCTARBALL/$ME.tar.gz
cd $ME

sed -i "s|unsigned int client_addr_size|socklen_t client_addr_size|" src/tcptunnel.c
$CC -Wall -Isrc -I$ANDROID/include -L$ANDROID/lib --sysroot=$ANDROID $PIEFLAG -o tcptunnel src/tcptunnel.c

rm -rf ../$DISTBIN/$ME
mkdir -p ../$DISTBIN/$ME/$DISTBIN
cp tcptunnel ../$DISTBIN/$ME/$DISTBIN
cd ..
rm -rf $ME

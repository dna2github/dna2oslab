#/bin/bash
set -xe

MEDIR=$(cd `dirname $0`; pwd)
ME=srelay-0.4.8b6

cd $MEDIR
source env.sh
source common.sh

cd ..
rm -rf $ME
fetch_source $ME.tar.gz http://downloads.sourceforge.net/project/socks-relay/socks-relay/srelay-0.4.8/srelay-0.4.8b6.tar.gz
tar zxf $SRCTARBALL/$ME.tar.gz
cd $ME
mkdir -p dist

sed -i "s|.*strcmp.*|{|g" auth-pwd.c # disable auth
CONFIG="-DLINUX -DUSE_THREAD -DHAVE_SYS_RESOURCE_H -DHAVE_LIMITS_H -DHAVE_SOCKLEN_T -DHAVE_U_INT8_T -DHAVE_U_INT16_T -DHAVE_U_INT32_T --sysroot=$ANDROID"
$CC -I. -I$ANDROID/include $CONFIG -DSYSCONFDIR=\"./\" -O2 -Wall -c init.c
$CC -I. -I$ANDROID/include $CONFIG -DSYSCONFDIR=\"./\" -O2 -Wall -c readconf.c
$CC -I. -I$ANDROID/include $CONFIG -DSYSCONFDIR=\"./\" -O2 -Wall -c util.c
$CC -I. -I$ANDROID/include $CONFIG -DSYSCONFDIR=\"./\" -O2 -Wall -c socks.c
$CC -I. -I$ANDROID/include $CONFIG -DSYSCONFDIR=\"./\" -O2 -Wall -c relay.c
$CC -I. -I$ANDROID/include $CONFIG -DSYSCONFDIR=\"./\" -O2 -Wall -c main.c
$CC -I. -I$ANDROID/include $CONFIG -DSYSCONFDIR=\"./\" -O2 -Wall -c auth-pwd.c
$CC -I. -I$ANDROID/include $CONFIG -DSYSCONFDIR=\"./\" -O2 -Wall -c get-bind.c
$CC -I. -I$ANDROID/include $CONFIG -L$ANDROID/lib init.o readconf.o util.o socks.o relay.o main.o auth-pwd.o get-bind.o -o srelay

mkdir -p $MEDIR/../bin/$ME/{bin,share}
cp srelay $MEDIR/../bin/$ME/bin/
cp srelay.conf $MEDIR/../bin/$ME/share/
cd ..
rm -rf $ME

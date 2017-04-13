#/bin/bash
set -xe

# please compile openssl first
MEDIR=$(cd `dirname $0`; pwd)
ME=ip_relay_1.1

cd $MEDIR
source env.sh
source common.sh

cd ..
rm -rf $ME
fetch_source $ME.zip "https://iweb.dl.sourceforge.net/project/iprelay/iprelay_1.1.112705/IP%20Relay%20version%201.1.112705/ip_relay_1.1.112705.zip"
unzip $SRCTARBALL/$ME.zip
cd $ME
mkdir -p dist

sed -n '1,23p' src/lib_ip_relay.h > src/lib_ip_relay.h.fix
echo "#include <unistd.h>" >> src/lib_ip_relay.h.fix
sed -n '24,$p' src/lib_ip_relay.h >> src/lib_ip_relay.h.fix
mv src/lib_ip_relay.h src/lib_ip_relay.h.bak
mv src/lib_ip_relay.h.fix src/lib_ip_relay.h
CONFIG="--sysroot=$ANDROID $PIEFLAG"
$CC $CONFIG -Isrc -I$ANDROID/include -L$ANDROID/lib src/lib_ip_relay.c src/ip_relay.c -o iprelay

mkdir -p ../$DISTBIN/$ME/bin
cp iprelay ../$DISTBIN/$ME/bin
cd ..
rm -rf $ME

#/bin/bash
set -xe

# please compile openssl first
MEDIR=$(cd `dirname $0`; pwd)
ME=haproxy-1.7.1

cd $MEDIR
source env.sh
source common.sh

cd ..
rm -rf $ME
fetch_source $ME.tar.gz http://www.haproxy.org/download/1.7/src/haproxy-1.7.1.tar.gz
tar zxf $SRCTARBALL/$ME.tar.gz
cd $ME
mkdir -p dist

sed -i "s|^PREFIX = .*$|PREFIX = $MEDIR/../$ME/dist|" Makefile
grep sys/select.h include/common/config.h || echo "#include <sys/select.h>" >> include/common/config.h
cat $MEDIR/haproxy/config.h >> $MEDIR/../$ME/include/common/config.h
make TARGET=generic PREFIX=$MEDIR/../$ME/dist CC="$CC --sysroot=$ANDROID -I$ANDROID/include -L$ANDROID/lib"
make_install $ME

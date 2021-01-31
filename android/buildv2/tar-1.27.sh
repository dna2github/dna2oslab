#/bin/bash
set -xe

MEDIR=$(cd `dirname $0`; pwd)
ME=tar-1.27

cd $MEDIR
source env.sh

cd ..
rm -rf $ME
fetch_source $ME.tar.gz http://ftp.gnu.org/gnu/tar/tar-1.27.tar.gz
tar zxf $ENVSRCTARBALL/$ME.tar.gz
cd $ME
mkdir -p dist

sed -i "s/^mkfifo/_mkfifo/" gnu/mkfifo.c

./configure --prefix=$MEDIR/../$ME/dist/ $CROSS_COMPILE

sed -i "s/.*FCNTL_DUPFD_BUGGY.*//" config.h

make
make_install $ME

#/bin/bash
set -xe

MEDIR=$(cd `dirname $0`; pwd)
ME=pcre-8.37

cd $MEDIR
source env.sh
source common.sh

cd ..
rm -rf $ME
fetch_source $ME.tar.gz http://downloads.sourceforge.net/project/pcre/pcre/8.37/pcre-8.37.tar.gz
tar zxf $SRCTARBALL/$ME.tar.gz
cd $ME
mkdir -p dist

./configure $CONFIGFLAGS --prefix=$MEDIR/../$ME/dist/

make
make_install $ME


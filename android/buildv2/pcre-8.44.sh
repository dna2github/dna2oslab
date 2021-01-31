#/bin/bash
set -xe

MEDIR=$(cd `dirname $0`; pwd)
ME=pcre-8.44

cd $MEDIR
source env.sh

cd ..
rm -rf $ME
fetch_source $ME.tar.gz http://downloads.sourceforge.net/project/pcre/pcre/8.44/pcre-8.44.tar.gz
tar zxf $ENVSRCTARBALL/$ME.tar.gz
cd $ME
mkdir -p dist

./configure --prefix=$MEDIR/../$ME/dist/ $CROSS_COMPILE

make
rm -f dist/lib/*.la
make_install $ME


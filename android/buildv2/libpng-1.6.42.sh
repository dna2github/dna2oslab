#/bin/bash
set -xe

MEDIR=$(cd `dirname $0`; pwd)
ME=libpng-1.6.42

cd $MEDIR
source env.sh

cd ..
rm -rf $ME
fetch_source $ME.tar.gz https://jaist.dl.sourceforge.net/project/libpng/libpng16/1.6.42/libpng-1.6.42.tar.gz
tar zxf $ENVSRCTARBALL/$ME.tar.gz
cd $ME
mkdir -p dist

./configure --prefix=$MEDIR/../$ME/dist/ $CROSS_COMPILE

make
make_install $ME

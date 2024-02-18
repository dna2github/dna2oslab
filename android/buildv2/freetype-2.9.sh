#/bin/bash
set -xe

MEDIR=$(cd `dirname $0`; pwd)
ME=freetype-2.9

LIBPNG=libpng-1.6.42

cd $MEDIR
source env.sh

cd ..
rm -rf $ME
fetch_source $ME.tar.gz https://download.savannah.gnu.org/releases/freetype/freetype-2.9.tar.gz
tar zxf $ENVSRCTARBALL/$ME.tar.gz
cd $ME
mkdir -p dist

#sed -i "s/^mkfifo/_mkfifo/" gnu/mkfifo.c

LIBPNG_CFLAGS="-I$MEDIR/../$ENVDISTBIN/$LIBPNG/include" \
LIBPNG_LIBS="-L$MEDIR/../$ENVDISTBIN/$LIBPNG/lib" \
./configure --prefix=$MEDIR/../$ME/dist/ $CROSS_COMPILE

make
make_install $ME

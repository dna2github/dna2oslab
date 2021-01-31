#/bin/bash
set -xe

OPENSSL=openssl-1.1.1i
PCRE=pcre-8.44

# please compile openssl first
MEDIR=$(cd `dirname $0`; pwd)
ME=wget2-1.99.2

if [ ! -d $MEDIR/../$ENVDISTBIN/$OPENSSL ]; then
   echo please run ${OPENSSL}.sh first
fi
if [ ! -d $MEDIR/../$ENVDISTBIN/$PCRE ]; then
   echo please run ${PCRE}.sh first
fi

cd $MEDIR
source env.sh

cd ..
rm -rf $ME
fetch_source $ME.tar.gz http://ftp.gnu.org/gnu/wget/wget2-1.99.2.tar.gz
tar zxf $ENVSRCTARBALL/$ME.tar.gz
cd $ME
mkdir -p dist

export CFLAGS="$CFLAGS -I$MEDIR/../$ENVDISTBIN/$OPENSSL/include -I$MEDIR/../$ENVDISTBIN/$PCRE/include"
export LDFLAGS="$LDFLAGS -L$MEDIR/../$ENVDISTBIN/$OPENSSL/lib -L$MEDIR/../$ENVDISTBIN/$PCRE/lib"
./configure --prefix=$MEDIR/../$ME/dist/ $CROSS_COMPILE --with-openssl --with-ssl=openssl --disable-nls

# see also https://code.woboq.org/gcc/include/glob.h.html
sed -i 's|__GLOB_FLAGS|0x7eff|g' lib/glob.c
sed -i 's|GLOB_TILDE_CHECK|0x4000|g' lib/glob.c
sed -i 's|GLOB_ONLYDIR|0x2000|g' lib/glob.c
sed -i 's|GLOB_PERIOD|0x80|g' lib/glob.c
sed -i 's|GLOB_TILDE_CHECK|0x4000|g' src/options.c 
sed -i 's|GLOB_ONLYDIR|0x2000|g' src/utils.c

make
make_install $ME

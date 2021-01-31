#/bin/bash
set -xe

MEDIR=$(cd `dirname $0`; pwd)
ME=postgresql-13.1
OPENSSL=openssl-1.1.1i

cd $MEDIR
source env.sh

cd ..
rm -rf $ME
fetch_source $ME.tar.gz https://ftp.postgresql.org/pub/source/v13.1/postgresql-13.1.tar.gz
tar zxf $ENVSRCTARBALL/$ME.tar.gz
cd $ME
mkdir -p dist

$CC -I$MEDIR/shm -c -o `pwd`/__shm.o $MEDIR/shm/shm.c
$CC -I$MEDIR/langinfo -c -o `pwd`/__langinfo.o $MEDIR/langinfo/nl_langinfo.c

OPENSSL_LIB_DIR=`pwd`/../dist/$OPENSSL/lib
export ac_cv_file__dev_urandom=no
export CFLAGS="$CFLAGS -I`pwd`/../dist/$OPENSSL/include"
export LDFLAGS="$LDFLAGS -L$OPENSSL_LIB_DIR"
export LIBS="`pwd`/__shm.o `pwd`/__langinfo.o $OPENSSL_LIB_DIR/libssl.a $OPENSSL_LIB_DIR/libcrypto.a"
./configure --prefix=$MEDIR/../$ME/dist/ --host=armv8a-linux --target=armv8a-linux \
   --without-readline --with-openssl

sed -i 's|\$(ZIC) -d .\$(DESTDIR)\$(datadir)/timezone. \$(ZIC_OPTIONS) \$(TZDATAFILES)|echo skip zic ...|' src/timezone/Makefile

make
make_install $ME

cat <<EOF
[!] Please compile postgres on your build machine again and do 'make install'
    to get /share/timezone folder and copy it to android postgres:
       --> $MEDIR/../$ENVDISTBIN/$ME/share
EOF

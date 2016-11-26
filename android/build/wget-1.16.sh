#/bin/bash
set -xe

# please compile openssl first
MEDIR=$(cd `dirname $0`; pwd)
ME=wget-1.16

cd $MEDIR
source env.sh
source common.sh
LDFLAGS="$LDFLAGS -L$MEDIR/../bin/openssl-1.0.1j/lib"
CFLAGS="$CFLAGS -I$MEDIR/../bin/openssl-1.0.1j/include -I$MEDIR/../bin/openssl-1.0.1j/include/openssl -L$MEDIR/../bin/openssl-1.0.1j/lib"

cd ..
rm -rf $ME
fetch_source $ME.tar.gz http://ftp.gnu.org/gnu/wget/wget-1.16.tar.gz
tar zxf $SRCTARBALL/$ME.tar.gz
cd $ME
mkdir -p dist

# You'd better to change this #define in one line manually
# or change the regex to make it one line, then build will pass
sed -i "s/\*ncols)/ncols)/" src/progress.c

./configure $CONFIGFLAGS --prefix=$MEDIR/../$ME/dist/ --with-ssl=openssl --disable-nls

make
make_install $ME

#/bin/bash
set -xe

# compile gmp first
MEDIR=$(cd `dirname $0`; pwd)
ME=mpfr-3.1.3

cd $MEDIR
source env.sh
source common.sh

cd ..
rm -rf $ME
fetch_source $ME.tar.gz https://ftp.gnu.org/gnu/mpfr/mpfr-3.1.3.tar.gz
tar zxf $SRCTARBALL/$ME.tar.gz
cd $ME
mkdir -p dist

./configure $CONFIGFLAGS --prefix=$MEDIR/../$ME/dist/ \
    --with-gmp=$MEDIR/../$DISTBIN/gmp-6.1.2 \
    --with-sysroot=$ANDROID

make

find $MEDIR/../$ME/dist -name "*.la" | xargs rm -f

make_install $ME

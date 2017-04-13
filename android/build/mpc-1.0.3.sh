#/bin/bash
set -xe

# compile gmp, mpfr first
MEDIR=$(cd `dirname $0`; pwd)
ME=mpc-1.0.3

cd $MEDIR
source env.sh
source common.sh

cd ..
rm -rf $ME
fetch_source $ME.tar.gz http://ftp.gnu.org/gnu/mpc/mpc-1.0.3.tar.gz
tar zxf $SRCTARBALL/$ME.tar.gz
cd $ME
mkdir -p dist

./configure $CONFIGFLAGS --prefix=$MEDIR/../$ME/dist/ \
    --with-gmp=$MEDIR/../$DISTBIN/gmp-6.1.2 \
    --with-mpfr=$MEDIR/../$DISTBIN/mpfr-3.1.3 \
    --with-sysroot=$ANDROID

make
make_install $ME

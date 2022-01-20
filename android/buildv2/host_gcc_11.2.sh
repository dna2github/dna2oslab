#/bin/bash
set -xe

MEDIR=$(cd `dirname $0`; pwd)
ME=gcc-11.2.0

mkdir -p $MEDIR/local
cd $MEDIR/local

GMP=gmp-6.2.1
MPFR=mpfr-4.1.0
MPC=mpc-1.2.1

test -f ${GMP}.tar.bz2 || curl -L -O https://ftp.gnu.org/gnu/gmp/${GMP}.tar.bz2
tar jxf ${GMP}.tar.bz2
pushd ${GMP}
mkdir -p dist
./configure --prefix=$MEDIR/local/${GMP}/dist
make -j4
make install
popd

test -f ${MPFR}.tar.gz || curl -L -O https://ftp.gnu.org/gnu/mpfr/${MPFR}.tar.gz
tar zxf ${MPFR}.tar.gz
pushd ${MPFR}
mkdir -p dist
./configure --prefix=$MEDIR/local/${MPFR}/dist --with-gmp=$MEDIR/local/${GMP}/dist
make -j4
make install
popd

test -f ${MPC}.tar.gz || curl -L -O https://ftp.gnu.org/gnu/mpc/${MPC}.tar.gz
tar zxf ${MPC}.tar.gz
pushd ${MPC}
mkdir -p dist
./configure --prefix=$MEDIR/local/${MPC}/dist --with-gmp=$MEDIR/local/${GMP}/dist --with-mpfr=$MEDIR/local/${MPFR}/dist
make -j4
make install
popd

rm -rf $ME
test -f ${ME}.tar.xz || curl -L -O https://ftp.gnu.org/gnu/gcc/${ME}/${ME}.tar.xz
tar Jxf ${ME}.tar.xz
cd $ME
mkdir -p dist

./configure --prefix=$MEDIR/local/$ME/dist/ \
    --with-gmp=$MEDIR/local/${GMP}/dist \
    --with-mpfr=$MEDIR/local/${MPFR}/dist \
    --with-mpc=$MEDIR/local/${MPC}/dist \
    --disable-multilib

make
make install

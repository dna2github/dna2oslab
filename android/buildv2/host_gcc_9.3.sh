#/bin/bash
set -xe

MEDIR=$(cd `dirname $0`; pwd)
ME=gcc-9.3.0

mkdir -p $MEDIR/local
cd $MEDIR/local

test -f gmp-6.1.2.tar.bz2 || wget https://ftp.gnu.org/gnu/gmp/gmp-6.1.2.tar.bz2
tar jxf gmp-6.1.2.tar.bz2
pushd gmp-6.1.2
mkdir -p dist
./configure --prefix=$MEDIR/local/gmp-6.1.2/dist
make -j4
make install
popd

test -f mpfr-3.1.3.tar.gz || wget https://ftp.gnu.org/gnu/mpfr/mpfr-3.1.3.tar.gz
tar zxf mpfr-3.1.3.tar.gz
pushd mpfr-3.1.3
mkdir -p dist
./configure --prefix=$MEDIR/local/mpfr-3.1.3/dist --with-gmp=$MEDIR/local/gmp-6.1.2/dist
make -j4
make install
popd

test -f mpc-1.0.3.tar.gz || wget https://ftp.gnu.org/gnu/mpc/mpc-1.0.3.tar.gz
tar zxf mpc-1.0.3.tar.gz
pushd mpc-1.0.3
mkdir -p dist
./configure --prefix=$MEDIR/local/mpc-1.0.3/dist --with-gmp=$MEDIR/local/gmp-6.1.2/dist --with-mpfr=$MEDIR/local/mpfr-3.1.3/dist
make -j4
make install
popd

rm -rf $ME
test -f ${ME}.tar.xz || wget https://ftp.gnu.org/gnu/gcc/${ME}/${ME}.tar.xz
tar Jxf ${ME}.tar.xz
cd $ME
mkdir -p dist

./configure --prefix=$MEDIR/local/$ME/dist/ \
    --with-gmp=$MEDIR/local/gmp-6.1.2/dist \
    --with-mpfr=$MEDIR/local/mpfr-3.1.3/dist \
    --with-mpc=$MEDIR/local/mpc-1.0.3/dist \
    --disable-multilib

make
make install

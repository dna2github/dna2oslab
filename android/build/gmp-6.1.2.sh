#/bin/bash
set -xe

MEDIR=$(cd `dirname $0`; pwd)
ME=gmp-6.1.2

cd $MEDIR
source env.sh
source common.sh

cd ..
rm -rf $ME
fetch_source $ME.tar.bz2 https://ftp.gnu.org/gnu/gmp/gmp-6.1.2.tar.bz2
tar jxf $SRCTARBALL/$ME.tar.bz2
cd $ME
mkdir -p dist

./configure $CONFIGFLAGS --prefix=$MEDIR/../$ME/dist/

make

find $MEDIR/../$ME/dist -name "*.la" | xargs rm -f

make_install $ME

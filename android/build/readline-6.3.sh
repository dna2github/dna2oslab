#/bin/bash

echo "================================="
echo "Please compile ncurses-5.9 first"
echo "================================="
sleep 1

set -xe

MEDIR=$(cd `dirname $0`; pwd)
ME=readline-6.3

cd $MEDIR
source env.sh
source common.sh

cd ..
rm -rf $ME
fetch_source $ME.tar.gz http://ftp.gnu.org/gnu/readline/readline-6.3.tar.gz
tar zxf $SRCTARBALL/$ME.tar.gz
cd $ME
mkdir -p dist

sed -i 's|\$as_echo_n "checking for wcwidth broken |bash_cv_wcwidth_broken=yes; $as_echo_n "checking for wcwidth broken |g' configure

export CFLAGS="$CFLAGS -I$MEDIR/../$DISTBIN/ncurses-5.9/include -I$MEDIR/../$DISTBIN/ncurses-5.9/include/ncurses"
export CXXFLGAS="$CXXFLAGS -I$MEDIR/../$DISTBIN/ncurses-5.9/include -I$MEDIR/../$DISTBIN/ncurses-5.9/include/ncurses"
export LDFLAGS="$LDFLAGS -L$MEDIR/../$DISTBIN/ncurses-5.9/lib"

./configure --host=arm-unknown-linux-gnu --build=x86_64-unknown-linux-gnu --prefix=$MEDIR/../$ME/dist/ --with-curses

make
make_install $ME


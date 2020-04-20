#/bin/bash
set -xe

MEDIR=$(cd `dirname $0`; pwd)
ME=ncurses-5.9

cd $MEDIR
source env.sh
source common.sh

cd ..
rm -rf $ME
fetch_source $ME.tar.gz http://ftp.gnu.org/gnu/ncurses/ncurses-5.9.tar.gz
tar zxf $SRCTARBALL/$ME.tar.gz
cd $ME
mkdir -p dist

# hardcord locale info
sed -i "s/#define isDecimalPoint(c) .*/#define isDecimalPoint(c) ((c) == '.')/" form/fty_num.c
sed -i "s/localeconv()/NULL/" form/fty_num.c
sed -i 's|NCursesUserForm (NCursesFormField Fields|NCursesUserForm (NCursesFormField *Fields|g' c++/cursesf.h
sed -i 's|NCursesUserMenu (NCursesMenuItem Items|NCursesUserMenu (NCursesMenuItem *Items|g' c++/cursesm.h

./configure $CONFIGFLAGS --prefix=$MEDIR/../$ME/dist/ \
    --disable-home-terminfo --without-ada

make
make_install $ME


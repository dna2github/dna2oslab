#/bin/bash
set -xe

MEDIR=$(cd `dirname $0`; pwd)
ME=ncurses-6.2

cd $MEDIR
source env.sh

cd ..
rm -rf $ME
fetch_source $ME.tar.gz http://ftp.gnu.org/gnu/ncurses/ncurses-6.2.tar.gz
tar zxf $ENVSRCTARBALL/$ME.tar.gz
cd $ME
mkdir -p dist

# hardcord locale info
sed -i "s/#define isDecimalPoint(c) .*/#define isDecimalPoint(c) ((c) == '.')/" form/fty_num.c
sed -i "s/localeconv()/NULL/" form/fty_num.c
sed -i 's|NCursesUserForm (NCursesFormField Fields|NCursesUserForm (NCursesFormField *Fields|g' c++/cursesf.h
sed -i 's|NCursesUserMenu (NCursesMenuItem Items|NCursesUserMenu (NCursesMenuItem *Items|g' c++/cursesm.h

./configure --prefix=$MEDIR/../$ME/dist/ $CROSS_COMPILE \
    --disable-home-terminfo --without-ada

# remove -s to avoid strip
find . -name Makefile | xargs sed -i 's|INSTALL} -s|INSTALL}|g'
sed -i 's|./run_tic.sh|-c "echo skip run_tic.sh"|g' misc/Makefile

make
make_install $ME


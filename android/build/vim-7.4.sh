#/bin/bash
set -xe

# please compile ncurses
MEDIR=$(cd `dirname $0`; pwd)
ME=vim-7.4

cd $MEDIR
source common.sh
export CFLAGS="$CFLAGS -I$MEDIR/../bin/ncurses-5.9/include -I$MEDIR/../bin/ncurses-5.9/include/ncurses"
export CXXFLAGS="$CXXFLAGS -I$MEDIR/../bin/ncurses-5.9/include -I$MEDIR/../bin/ncurses-5.9/include/ncurses"
export LDFLAGS="$LDFLAGS -L$ANDROIDLIB -L$MEDIR/../bin/ncurses-5.9/lib"
export vim_cv_toupper_broken="set"
export vim_cv_getcwd_broken="yes"
export vim_cv_stat_ignores_slash="yes"
export vim_cv_terminfo="yes"
export vim_cv_tty_group="root"
export vim_cv_tty_mode="0620"
export vim_cv_memmove_handles_overlap="yes"
export vim_cv_memcpy_handles_overlap="yes"

cd ..
rm -rf $ME
tar jxf $SRCTARBALL/$ME.tar.bz2
mv vim74 $ME
cd $ME
mkdir -p dist

sed -i "s/mblen(NULL, 0)/1/" src/mbyte.c
sed -i "s/mblen(buf, (size_t)1)/1/" src/mbyte.c
cp $ANDROID/lib/crtbegin_dynamic.o $MEDIR/../$ME/src/crtbegin_dynamic.o
cp $ANDROID/lib/crtend_android.o $MEDIR/../$ME/src/crtend_android.o

./configure $CONFIGFLAGS --prefix=$MEDIR/../$ME/dist/ \
    --disable-gpm --disable-sysmouse --disable-nls --disable-gtktest --disable-acl \
    --disable-netbeans --disable-darwin --disable-selinux --disable-xsmp --disable-xsmp-interact \
    --enable-gui=no --with-tlib=ncurses

make
make_install $ME

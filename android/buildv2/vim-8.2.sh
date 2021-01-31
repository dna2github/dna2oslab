#/bin/bash
set -xe

# please compile ncurses
MEDIR=$(cd `dirname $0`; pwd)
ME=vim-8.2.2434
NCURSES=ncurses-6.2

cd $MEDIR
source env.sh
export CFLAGS="$CFLAGS -I$MEDIR/../$ENVDISTBIN/$NCURSES/include -I$MEDIR/../$ENVDISTBIN/$NCURSES/include/ncurses"
export CXXFLAGS="$CXXFLAGS -I$MEDIR/../$ENVDISTBIN/$NCURSES/include -I$MEDIR/../$ENVDISTBIN/$NCURSES/include/ncurses"
export LDFLAGS="$LDFLAGS -L$MEDIR/../$ENVDISTBIN/$NCURSES/lib"
export vim_cv_tgetent="zero"
export vim_cv_toupper_broken="set"
export vim_cv_getcwd_broken="yes"
export vim_cv_stat_ignores_slash="yes"
export vim_cv_terminfo="yes"
export vim_cv_tty_group="root"
export vim_cv_tty_mode="0620"
export vim_cv_memmove_handles_overlap="yes"
export vim_cv_memcpy_handles_overlap="yes"
export ac_cv_small_wchar_t="no"

cd ..
rm -rf $ME
fetch_source $ME.tar.gz https://github.com/vim/vim/archive/v8.2.2434.tar.gz
tar zxf $ENVSRCTARBALL/$ME.tar.gz
cd $ME
mkdir -p dist

#sed -i "s/mblen(NULL, 0)/1/" src/mbyte.c
#sed -i "s/mblen(buf, (size_t)1)/1/" src/mbyte.c
#touch src/strings.h

./configure --prefix=$MEDIR/../$ME/dist/ $CROSS_COMPILE \
    --disable-gpm --disable-sysmouse --disable-nls --disable-gtktest --disable-acl \
    --disable-netbeans --disable-darwin --disable-selinux --disable-xsmp --disable-xsmp-interact \
    --enable-gui=no --with-tlib=ncurses --without-x

make || echo "error on osdef.h (some duplicated function def)"

sed -i "s/.*tgetent.*//" src/auto/osdef.h
sed -i "s/.*tputs.*//" src/auto/osdef.h
sed -i "s/.*tgoto.*//" src/auto/osdef.h
sed -i "s/.*tgetflag.*//" src/auto/osdef.h
sed -i "s/.*tgetnum.*//" src/auto/osdef.h

make
make_install $ME

#/bin/bash

echo "===================================================================="
echo "to make pgen on Mac, please search for next '-lutil' in this script"
echo "and then replace it with '-framework CoreFoundation'"
echo "===================================================================="

set -xe

# dependency:
# please compile openssl zlib ncurses sqlite first
# if wanna support command line history, compile readline
NCURSES=ncurses-5.9
SQLITE=sqlite-autoconf-3080701
OPENSSL=openssl-1.0.1p
ZLIB=zlib-1.2.8

MEDIR=$(cd `dirname $0`; pwd)
ME=Python-2.7.13

cd $MEDIR
source env.sh
source common.sh

cd ..
rm -rf $ME
fetch_source $ME.tgz https://www.python.org/ftp/python/2.7.13/Python-2.7.13.tgz
tar zxf $SRCTARBALL/$ME.tgz
cd $ME
mkdir -p dist

LIB_INCLUDE="-I$MEDIR/../$DISTBIN/$NCURSES/include -I$MEDIR/../$DISTBIN/$NCURSES/include/ncurses -I$MEDIR/../$DISTBIN/$OPENSSL/include -I$MEDIR/../$DISTBIN/$OPENSSL/include/openssl -I$MEDIR/../$DISTBIN/$SQLITE/include -I$MEDIR/../$DISTBIN/$ZLIB/include -I. -I$ANDROID/include"
LIB_LIB="-L$MEDIR/../$DISTBIN/$NCURSES/lib -L$MEDIR/../$DISTBIN/$OPENSSL/lib -L$MEDIR/../$DISTBIN/$SQLITE/lib -L$MEDIR/../$DISTBIN/$ZLIB/lib -L. -L$ANDROID/lib"

# fix ptmx and ptc
# please investigate your Android in the /dev
# if there is /dev/ptmx, ac_cv_file__dev_ptmx can be yes; or it should be no
# the sane for /dev/ptc
sed -i "s|if test \"x\$cross_compiling\" = xyes; then|ac_cv_file__dev_ptmx=yes; ac_cv_file__dev_ptc=no; if test \"x\$cross_compiling\" = xyes; then|" configure

# hardcode to fix locale problem
# better to write a locale.h to fix it
sed -i "s|.*localeconv().*||" Objects/stringlib/localeutil.h
sed -i "s|locale_data->grouping|\"\"|" Objects/stringlib/localeutil.h
sed -i "s|locale_data->thousands_sep|\"\"|" Objects/stringlib/localeutil.h
sed -i "s|.*localeconv().*||" Objects/stringlib/formatter.h
sed -i "s|locale_data->grouping|\"\"|" Objects/stringlib/formatter.h
sed -i "s|locale_data->thousands_sep|\"\"|" Objects/stringlib/formatter.h
sed -i "s|locale_data->decimal_point|\".\"|" Objects/stringlib/formatter.h
sed -i "s|.*localeconv().*||" Python/pystrtod.c
sed -i "s|locale_data->decimal_point|\".\"|" Python/pystrtod.c
sed -i "s|I_PUSH|0x5302|" Modules/posixmodule.c
sed -i "s|p->pw_gecos|\"\"|" Modules/pwdmodule.c

cp $MEDIR/python/Setup.dist Modules/
cp $MEDIR/python/socketmodule.c Modules/

CFLAGS="$CFLAGS --sysroot=$ANDROID $LIB_INCLUDE" \
CXXFLAGS="$CXXFLAGS --sysroot=$ANDROID $LIB_INCLUDE" \
LDFLAGS="$LDFLAGS --sysroot=$ANDROID $LIB_LIB" \
LDLAST="$PIEFLAG" \
./configure --host=arm-unknown-linux-gnu --build=x86_64-unknown-linux-gnu \
            --enable-ipv6 \
            --prefix=$MEDIR/../$ME/dist

# XXX: Fake the pgen, hope it will be fixed in the python build script
# python build script build an executable binary 'pgen' to patch source
# some files; however, with cross-compiling eanbled, pgen will be built
# to the target binary not host binary, so that it cannot be executed
sed -i "s|\$(PGEN):.*|\$(PGEN):|" Makefile
sed -i "s|\$(CC) \$(OPT) \$(LDFLAGS) \$(PGENOBJS) \$(LIBS) -o \$(PGEN)|gcc -pthread -DNDEBUG -fwrapv -O3 -Wall -Wstrict-prototypes  Parser/acceler.c Parser/grammar1.c Parser/listnode.c Parser/node.c Parser/parser.c Parser/parsetok.c Parser/bitset.c Parser/metagrammar.c Parser/firstsets.c Parser/grammar.c Parser/pgen.c Objects/obmalloc.c Python/mysnprintf.c Python/pyctype.c Parser/tokenizer_pgen.c Parser/printgrammar.c Parser/pgenmain.c -lpthread -ldl -lutil -I. -IInclude -o Parser/pgen|" Makefile

export EX_INCDIR="['$ANDROID/include', '$MEDIR/../$DISTBIN/$SQLITE/include', '$MEDIR/../$DISTBIN/$NCURSES/include', '$MEDIR/../$DISTBIN/$ZLIB/include', '$MEDIR/../$DISTBIN/$OPENSSL/include']"
export EX_LIBDIR="['$ANDROID/lib', '$MEDIR/../$DISTBIN/$SQLITE/lib', '$MEDIR/../$DISTBIN/$NCURSES/lib', '$MEDIR/../$DISTBIN/$ZLIB/lib', '$MEDIR/../$DISTBIN/$OPENSSL/lib']"
export SQLITE_ON_ANDROID="/system/lib" # where sqlite.so is located on android device; here assume rooted android and sqlite3 in /system/lib
sed -i "s|\(inc_dirs = self\.compiler\.include_dirs\[:\]\)|\1;inc_dirs+=$EX_INCDIR;|" setup.py
sed -i "s|\(lib_dirs = self\.compiler\.library_dirs\[:\]\)|\1;lib_dirs+=$EX_LIBDIR;|" setup.py
sed -i "s|\(sqlite_inc_paths = \[\]\)|\1;sqlite_incdir='$MEDIR/../$DISTBIN/$SQLITE/include';sqlite_libdir='$MEDIR/../$DISTBIN/$SQLITE/lib'|" setup.py
sed -i "s|\(ssl_incs = find_file('openssl/ssl.h', inc_dirs,\)|ssl_incs=['$MEDIR/../$DISTBIN/$OPENSSL/include'];ssl_libs=['$MEDIR/../$DISTBIN/$OPENSSL/lib'];\1|" setup.py
sed -i "s|sqlite_extra_link_args = ()|sqlite_extra_link_args = ('-Wl,-search_paths_first','-Wl,-rpath,$SQLITE_ON_ANDROID')|" setup.py

make
make -i install
rm -rf ../$DISTBIN/$ME
mkdir -p ../$DISTBIN/$ME
mv dist/* ../$DISTBIN/$ME/
cd ..
rm -rf $ME

# fix runtime dependency; let python find libsqlite3.so
cp $DISTBIN/$SQLITE/lib/libsqlite3.so.0 $DISTBIN/$ME/lib/
rm $DISTBIN/$ME/bin/python
cat > $DISTBIN/$ME/bin/python << EOF
#!/system/bin/sh

cd \`dirname \$0\`
PYTHONBINDIR=\`pwd\`/../lib
export LD_LIBRARY_PATH="\$PYTHONBINDIR"
./python2
EOF
chmod 755 $DISTBIN/$ME/bin/python

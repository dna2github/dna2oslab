#/bin/bash

echo "===================================================================="
echo "to make pgen on Mac, please search for next '-lutil' in this script"
echo "and then replace it with '-framework CoreFoundation'"
echo "===================================================================="

set -xe

# please compile openssl zlib ncurses sqlite first
# if wanna support command line history, compile readline
MEDIR=$(cd `dirname $0`; pwd)
ME=Python-2.7.8

cd $MEDIR
source env.sh
source common.sh

cd ..
rm -rf $ME
fetch_source $ME.tgz https://www.python.org/ftp/python/2.7.8/Python-2.7.8.tgz
tar zxf $SRCTARBALL/$ME.tgz
cd $ME
mkdir -p dist

LIB_INCLUDE="-I$MEDIR/../bin/ncurses-5.9/include -I$MEDIR/../bin/ncurses-5.9/include/ncurses -I$MEDIR/../bin/openssl-1.0.1p/include -I$MEDIR/../bin/openssl-1.0.1p/include/openssl -I$MEDIR/../bin/sqlite-autoconf-3090200/include -I$MEDIR/../bin/zlib-1.2.8/include"
LIB_LIB="-L$MEDIR/../bin/ncurses-5.9/lib -L$MEDIR/../bin/openssl-1.0.1p/lib -L$MEDIR/../bin/sqlite-autoconf-3090200/lib -L$MEDIR/../bin/zlib-1.2.8/lib"
export CFLAGS="$CFLAGS $LIB_INCLUDE -R/system/lib -fvisibility=default -fPIE -pie"
export CXXFLAGS="$CXXFLAGS $LIB_INCLUDE -R/system/lib -fvisibility=default -fPIE -pie"
export LDFLAGS="$LDFLAGS $LIB_LIB -R/system/lib -fPIE -pie"

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

./configure --host=arm-unknown-linux-gnu --build=x86_64-unknown-linux-gnu \
            --enable-ipv6 \
            --prefix=$MEDIR/../$ME/dist

# XXX: Fake the pgen, hope it will be fixed in the python build script
# python build script build an executable binary 'pgen' to patch source
# some files; however, with cross-compiling eanbled, pgen will be built
# to the target binary not host binary, so that it cannot be executed
sed -i "s|\$(PGEN):.*|\$(PGEN):|" Makefile
sed -i "s|\$(CC) \$(OPT) \$(LDFLAGS) \$(PGENOBJS) \$(LIBS) -o \$(PGEN)|gcc -pthread -DNDEBUG -fwrapv -O3 -Wall -Wstrict-prototypes  Parser/acceler.c Parser/grammar1.c Parser/listnode.c Parser/node.c Parser/parser.c Parser/parsetok.c Parser/bitset.c Parser/metagrammar.c Parser/firstsets.c Parser/grammar.c Parser/pgen.c Objects/obmalloc.c Python/mysnprintf.c Python/pyctype.c Parser/tokenizer_pgen.c Parser/printgrammar.c Parser/pgenmain.c -lpthread -ldl -framework CoreFoundation -I. -IInclude -o Parser/pgen|" Makefile

cp $ANDROID/lib/*.o ./
mkdir -p build/temp.linux2-arm-2.7/libffi
cp $ANDROID/lib/*.o ./build/temp.linux2-arm-2.7/libffi

make
make -i install
rm -rf ../bin/$ME
mkdir -p ../bin/$ME
mv dist/* ../bin/$ME/
cd ..
rm -rf $ME

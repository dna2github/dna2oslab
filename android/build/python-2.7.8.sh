#/bin/bash
set -xe

# please compile openssl zlib first
MEDIR=$(cd `dirname $0`; pwd)
ME=python-2.7.8

cd $MEDIR
source common.sh

cd ..
rm -rf $ME
tar zxf $SRCTARBALL/$ME.tar.gz
mv Python-2.7.8 $ME

cd $ME
mkdir -p dist

export CFLAGS="$CFLAGS -I$MEDIR/../ncurses-5.9/include -I$MEDIR/../ncurses-5.9/include/ncurses -I$MEDIR/../openssl-1.0.1j/include -I$MEDIR/../openssl-1.0.1j/include/openssl -I$MEDIR/../sqlite-autoconf-3080701/include -I$MEDIR/../zlib-1.2.8/include -R/system/lib"
export CXXFLAGS="$CXXFLAGS -I$MEDIR/../ncurses-5.9/include -I$MEDIR/../ncurses-5.9/include/ncurses -I$MEDIR/../openssl-1.0.1j/include -I$MEDIR/../openssl-1.0.1j/include/openssl -I$MEDIR/../sqlite-autoconf-3080701/include -I$MEDIR/../zlib-1.2.8/include -R/system/lib"
export LDFLAGS="$LDFLAGS -L$MEDIR/../ncurses-5.9/lib -L$MEDIR/../openssl-1.0.1j/lib -L$MEDIR/../sqlite-autoconf-3080701/lib -L$MEDIR/../zlib-1.2.8/lib -R/system/lib"

# fix ptmx and ptc
# please investigate your Android in the /dev
# if there is /dev/ptmx, ac_cv_file__dev_ptmx can be yes; or it should be no
# the sane for /dev/ptc
sed -i "s|if test \"x\$cross_compiling\" = xyes; then|ac_cv_file__dev_ptmx=yes\nac_cv_file__dev_ptc=no\nif test \"x\$cross_compiling\" = xyes; then|" configure

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
sed -i "s|\$(CC) \$(OPT) \$(LDFLAGS) \$(PGENOBJS) \$(LIBS) -o \$(PGEN)|echo \"fake Parser/pgen\"|" Makefile
cp $MEDIR/python/pgen Parser/

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


#/bin/bash
set -xe

MEDIR=$(cd `dirname $0`; pwd)
ME=proot-5.3.0

cd $MEDIR
source env.sh

ZLIB=zlib-1.2.11
TALLOC=talloc-2.3.3
LIBARCHIVE=libarchive-3.5.2

DISTDIR=$MEDIR/../$ENVDISTBIN

if [ ! -d ${DISTDIR}/${ZLIB} ]; then
   bash $MEDIR/${ZLIB}.sh
fi

cd ..
rm -rf $ME
fetch_source $ME.tar.gz https://github.com/proot-me/proot/archive/refs/tags/v5.3.0.tar.gz
tar zxf $ENVSRCTARBALL/$ME.tar.gz
cd $ME
mkdir -p dist local staticlib/{lib,include}
cd local

git clone git://github.com/troydhanson/uthash.git --depth=1
cp uthash/src/* ../staticlib/include

fetch_source ${TALLOC}.tar.gz https://www.samba.org/ftp/talloc/${TALLOC}.tar.gz
tar zxf $ENVSRCTARBALL/${TALLOC}.tar.gz
cd ${TALLOC}
mkdir -p dist
./configure --prefix=`pwd`/dist --disable-python --cross-compile --cross-execute="echo -n linux #" --hostcc=gcc
make
${AR} rcs ../../staticlib/lib/libtalloc.a bin/default/talloc*.o bin/default/lib/replace/replace*.o
cp talloc.h ../../staticlib/include/talloc.h
cd ..

fetch_source ${LIBARCHIVE}.tar.gz https://libarchive.org/downloads/${LIBARCHIVE}.tar.gz
tar zxf $ENVSRCTARBALL/${LIBARCHIVE}.tar.gz
cd ${LIBARCHIVE}
mkdir -p dist
CFLAGS="-I${DISTDIR}/${ZLIB}/include -I`pwd`/contrib/android/include" \
LDFLAGS="-L${DISTDIR}/${ZLIB}/lib -static" ./configure --prefix=`pwd`/dist --without-xml2 ${CROSS_COMPILE}
sed -i 's|#define HAVE_FUTIME.*||g' config.h
sed -i 's|#define HAVE_LUTIMES.*||g' config.h
sed -i 's|#define HAVE_GETGRGID_R.*||g' config.h
sed -i 's|#define HAVE_GETGRNAM_R.*||g' config.h
sed -i 's|#define HAVE_ICONV.*||g' config.h
sed -i 's|#define HAVE_NL_LANGINFO.*||g' config.h
sed -i 's|#define HAVE_POSIX_SPAWNP.*||g' config.h
make
make install
cp dist/include/* ../../staticlib/include/
cp dist/lib/libarchive.a ../../staticlib/lib/libarchive.a
cp contrib/android/include/android_lf.h ../../staticlib/include/
cd ..
cd ..

sed -i "s|CFLAGS.*\+= ..shell pkg-config --cflags talloc libarchive.|CFLAGS += -DUSERLAND -I`pwd`/staticlib/include|" src/GNUmakefile
sed -i "s|LDFLAGS.*\+= ..shell pkg-config --libs talloc libarchive.|LDFLAGS += -static -L`pwd`/staticlib/lib -ltalloc -larchive|" src/GNUmakefile
sed -i "s|CC.*=.*gcc||" src/GNUmakefile
sed -i "s|STRIP.*=.*strip||" src/GNUmakefile
sed -i "s|OBJCOPY.*=.*objcopy||" src/GNUmakefile
sed -i "s|OBJDUMP.*=.*objdump||" src/GNUmakefile
sed -i "s|^CARE_LDFLAGS = .*|CARE_LDFLAGS = -L`pwd`/staticlib/lib -L${DISTEN}/${ZLIB}/lib -larchive -lz|" src/GNUmakefile
sed -i "s|get_current_dir_name|rep_get_current_dir_name|g" src/path/temp.c
unset CROSS_COMPILE
make -C src loader.elf build.h
make -C src proot care

rm -rf ${DISTDIR}/${ME}
mkdir -p ${DISTDIR}/${ME}/sbin
python ${MEDIR}/utils/align_fix.py src/proot
python ${MEDIR}/utils/align_fix.py src/care
cp src/proot ${DISTDIR}/${ME}/sbin/
cp src/care ${DISTDIR}/${ME}/sbin/
cp src/loader/loader ${DISTDIR}/${ME}/sbin/
cp src/loader.elf ${DISTDIR}/${ME}/sbin/
cd ..
rm -rf ${ME}

echo 'It is experimental build; not tested for further usage ...'
echo
echo 'tested:'
echo '   PROOT_NO_SECCOMP=1 PROOT_TMP_DIR=./tmp proot -0 -r ./root -b /dev:/dev /busybox ls'
echo '# it works; but when the program exits, throw:'
echo '# proot error: proot warning: signal 11 received from process 00000000'


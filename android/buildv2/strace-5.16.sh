#/bin/bash
set -xe

echo 'if want a static-linked strace, please run "bash strace-5.16.sh static"'

XSTATIC=$1
MEDIR=$(cd `dirname $0`; pwd)
ME=strace-5.16

cd $MEDIR
source env.sh

cd ..
rm -rf $ME
fetch_source $ME.tar.xz https://github.com/strace/strace/releases/download/v5.16/strace-5.16.tar.xz
tar Jxf $ENVSRCTARBALL/$ME.tar.xz
cd $ME
mkdir -p dist

export CC="$COMPILERDIR/${ENVTARGET}28-clang"
export CXX="$COMPILERDIR/${ENVTARGET}28-clang++"
export CROSS_COMPILE="--build=x86_64-linux --host=arm64 --target=arm64"
if [ "x${XSTATIC}" == "xstatic" ]; then
   LDFLAGS="-static" \
   ./configure --prefix=`pwd`/dist --enable-mpers=check ${CROSS_COMPILE}
else
   ./configure --prefix=`pwd`/dist --enable-mpers=check ${CROSS_COMPILE}
fi
find . -name Makefile | xargs -I {} sed -i 's|-Werror||' {}

make

DISTDIR=$MEDIR/../$ENVDISTBIN
rm -rf ${DISTDIR}/${ME}
mkdir -p ${DISTDIR}/${ME}/sbin
python ${MEDIR}/utils/align_fix.py src/strace
cp src/strace ${DISTDIR}/${ME}/sbin/
cd ..
rm -rf ${ME}

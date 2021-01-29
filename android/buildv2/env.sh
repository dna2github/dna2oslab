#/bin/bash

SELF=$(cd `dirname $0`; pwd)

export NDK=""
export ENVSRCTARBALL=""
export HOST_GCC_DIR=""
export ENVDISTBIN="dst"
export ENVHOST=linux-x86_64
export ENVTARGET=aarch64-linux-android
export ENVANDROIDVER=23

if [ -f $SELF/local/env.sh ]; then
   source $SELF/local/env.sh
fi

if [ "$NDK" == "" ]; then
   echo 'check:    ENVHOST, ENVTARGET, ENVANDROIDVER'
   echo
   echo 'run cmd:  mkdir local; touch local/env.sh'
   echo 'fill:     NDK, ENVSRCTARBALL'
   echo 'optional: HOST_GCC_DIR'
   exit 0
fi

export COMPILERDIR="$NDK/toolchains/llvm/prebuilt/$ENVHOST/bin"
export CC="$COMPILERDIR/${ENVTARGET}${ENVANDROIDVER}-clang"
export CXX="$COMPILERDIR/${ENVTARGET}${ENVANDROIDVER}-clang++"
export LD="$COMPILERDIR/$ENVTARGET-ld"
export AS="$COMPILERDIR/$ENVTARGET-as"
export AR="$COMPILERDIR/$ENVTARGET-ar"
export STRIP="$COMPILERDIR/$ENVTARGET-strip"
export OBJCOPY="$COMPILERDIR/$ENVTARGET-objcopy"
export OBJDUMP="$COMPILERDIR/$ENVTARGET-objdump"
export RANLIB="$COMPILERDIR/$ENVTARGET-ranlib"
export NM="$COMPILERDIR/$ENVTARGET-nm"
export STRINGS="$COMPILERDIR/$ENVTARGET-strings"
export READELF="$COMPILERDIR/$ENVTARGET-readelf"

export ANDROID="$COMPILERDIR/../sysroot"
#export PIEFLAG=""
#if [ "$ANDROID_VERSION" -gt 22 ]; then
#  export PIEFLAG="-fPIE -pie"
#fi

#export CROSSFLAGS="--build=x86_64-linux --host=arm-eabi --target=arm-eabi"
#export CONFIGFLAGS="$CROSSFLAGS --with-sysroot=$ANDROID"

function make_install() {
# $1: package name
  make install
  rm -rf ../$ENVDISTBIN/$1
  mkdir -p ../$ENVDISTBIN/$1
  mv dist/* ../$ENVDISTBIN/$1/
  cd ..
  rm -rf $1
}

function fetch_source() {
# $1: package file name, e.g. vim-7.4.0001.tar.gz
# $2: source url
  test -f "$ENVSRCTARBALL/$1" || curl -k -L -o "$ENVSRCTARBALL/$1" "$2"
  test -f "$ENVSRCTARBALL/$1" || exit 1
}


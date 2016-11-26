#/bin/bash

echo "Please configure this common.sh ..."
echo "  SRCTARBALL, NDKDIR, ANDROID_VERSION, GCC_VERSION"
exit 1
# Then remove echo and exit

# Prepare Environment
export ANDROID_VERSION="{----- android version: e.g. 17 =Android 4.2 -----}"
export GCC_VERSION="{----- gcc version: e.g. 4.8 -----}"
export SRCTARBALL="{----- source tarball path -----}"
export NDKDIR="{----- Google Android NDK path -----}"
export COMPILER="$NDKDIR/toolchains/arm-linux-androideabi-${GCC_VERSION}/prebuilt/linux-x86_64/bin"
export CC="$COMPILER/arm-linux-androideabi-gcc"
export CXX="$COMPILER/arm-linux-androideabi-g++"
export CPP="$COMPILER/arm-linux-androideabi-cpp"
export LD="$COMPILER/arm-linux-androideabi-ld"
export AS="$COMPILER/arm-linux-androideabi-as"
export AR="$COMPILER/arm-linux-androideabi-ar"
export STRIP="$COMPILER/arm-linux-androideabi-strip"
export OBJCOPY="$COMPILER/arm-linux-androideabi-objcopy"
export OBJDUMP="$COMPILER/arm-linux-androideabi-objdump"
export RANLIB="$COMPILER/arm-linux-androideabi-ranlib"
export NM="$COMPILER/arm-linux-androideabi-nm"
export STRINGS="$COMPILER/arm-linux-androideabi-strings"
export READELF="$COMPILER/arm-linux-androideabi-readelf"

export ANDROID="$NDKDIR/platforms/android-${ANDROID_VERSION}/arch-arm/usr"
export CFLAGS="-I$ANDROID/include --sysroot=$ANDROID"
export CXXFLAGS="-I$ANDROID/include --sysroot=$ANDROID"
export CPPFLAGS="-I$ANDROID/include"
export LDFLAGS="-L$ANDROID/lib"

export CXXPLUS="$NDKDIR/sources/cxx-stl/gnu-libstdc++/${GCC_VERSION}"
export CXXCONFIGFLAGS="-I$CXXPLUS/include -I$CXXPLUS/libs/armeabi/include"
export CXXLIBPLUS="-L$CXXPLUS/libs/armeabi"
export CONFIGFLAGS="--build=x86_64-linux --host=arm-eabi --target=arm-eabi --with-sysroot=$ANDROID"

function make_install() {
# $1: package name
  make install
  rm -rf ../bin/$1
  mkdir -p ../bin/$1
  mv dist/* ../bin/$1/
  cd ..
  rm -rf $1
}

function fetch_source() {
# $1: package file name, e.g. vim-7.4.0001.tar.gz
# $2: source url
  test -f "$SRCTARBALL/$1" || curl -k -L -o "$SRCTARBALL/$1" "$2"
  test -f "$SRCTARBALL/$1" || exit 1
}

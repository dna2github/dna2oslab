#/bin/bash

SELF=$(cd `dirname $0`; pwd)

if [ ! -d "$SELF/local/toolchain" ]; then
   mkdir -p $SELF/local
   python $NDKDIR/build/tools/make_standalone_toolchain.py --arch arm64 --api $ANDROID_VERSION --install-dir $SELF/local/toolchain
fi
export COMPILER="$SELF/local/toolchain/bin"
export CC="$COMPILER/aarch64-linux-android-clang"
export CXX="$COMPILER/aarch64-linux-android-clang++"
export LD="$COMPILER/../aarch64-linux-android/bin/ld"
export AS="$COMPILER/../aarch64-linux-android/bin/as"
export AR="$COMPILER/../aarch64-linux-android/bin/ar"
export STRIP="$COMPILER/../aarch64-linux-android/bibn/strip"
export OBJCOPY="$COMPILER/../aarch64-linux-android/bin/objcopy"
export OBJDUMP="$COMPILER/../aarch64-linux-android/bin/objdump"
export RANLIB="$COMPILER/../aarch64-linux-android/bin/ranlib"
export NM="$COMPILER/../aarch64-linux-android/bin/nm"
export STRINGS="$COMPILER/../aarch64-linux-android/bin/strings"
export READELF="$COMPILER/../aarch64-linux-android/bin/readelf"

export ANDROID="$SELF/local/toolchain/sysroot"
export PIEFLAG=""
if [ "$ANDROID_VERSION" -gt 22 ]; then
  export PIEFLAG="-fPIE -pie"
fi

export CROSSFLAGS="--build=x86_64-linux --host=arm-eabi --target=arm-eabi"
export CONFIGFLAGS="$CROSSFLAGS --with-sysroot=$ANDROID"


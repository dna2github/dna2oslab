#/bin/bash

SELF=$(cd `dirname $0`; pwd)

if [ ! -d "$SELF/local/toolchain" ]; then
   mkdir -p $SELF/local
   python $NDKDIR/build/tools/make_standalone_toolchain.py --arch arm --api $ANDROID_VERSION --install-dir $SELF/local/toolchain
fi
export COMPILER="$SELF/local/toolchain/bin"
export CC="$COMPILER/arm-linux-androideabi-clang"
export CXX="$COMPILER/arm-linux-androideabi-clang++"
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

export ANDROID="$SELF/local/toolchain/sysroot"
export PIEFLAG=""
if [ "$ANDROID_VERSION" -gt 22 ]; then
  export PIEFLAG="-fPIE -pie"
fi

export CROSSFLAGS="--build=x86_64-linux --host=arm-eabi --target=arm-eabi"
export CONFIGFLAGS="$CROSSFLAGS --with-sysroot=$ANDROID"


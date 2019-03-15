#/bin/bash

set -xe

MEDIR=$(cd `dirname $0`; pwd)
ME=node-v10.10.0

cd $MEDIR
source env.sh

cd ..
rm -rf $ME
fetch_source $ME.tar.gz https://nodejs.org/dist/v10.10.0/node-v10.10.0.tar.gz
tar zxf $SRCTARBALL/$ME.tar.gz
cd $ME
mkdir -p dist out


cat <<EOF
=== Stage 1: build NodeJS on host machine ============================================
|   It is used to get "v8/torque" compiled and generate necessary source code files. |
|   Local GCC/LLVM-CLANG is required.                                                |
--------------------------------------------------------------------------------------
EOF
sleep 2
# build once to get $MEDIR/../$ME/out/Release/obj/gen/torque-generated
mkdir -p .xpatch
./configure
# -j9 is used to accelerate
make -j8
cp -r $MEDIR/../$ME/out/Release/obj/gen/torque-generated $MEDIR/../$ME/.xpatch/torque-generated
make clean

cat <<EOF
=== Stage 2: build NodeJS for Android ================================================
|   It is used to get "node" compiled and become able to run standalone on Android.  |
|   Android NDK is required.                                                         |
|                                                                                    |
|   NodeJS uses make-standalone-toolchain.sh by default but it is deprecated         |
|   Please feel free to switch to make-standalone-toolchain.py                       |
--------------------------------------------------------------------------------------
EOF
sleep 2
# common patch
sed -i "s|historyPath = path.join.*|historyPath = '/data/local/tmp/.node_repl_history';|" $MEDIR/../$ME/lib/internal/repl.js
sed -i "s/uv__getiovmax()/1024/" $MEDIR/../$ME/deps/uv/src/unix/fs.c
sed -i "s/uv__getiovmax()/1024/" $MEDIR/../$ME/deps/uv/src/unix/stream.c
sed -i "s/UV__POLLIN/1/g" $MEDIR/../$ME/deps/uv/src/unix/core.c
sed -i "s/UV__POLLOUT/4/g" $MEDIR/../$ME/deps/uv/src/unix/core.c

# see # see https://github.com/nodejs/node/issues/3074
sed -i 's/#define HAVE_GETSERVBYPORT_R 1/#undef HAVE_GETSERVBYPORT_R/' $MEDIR/../$ME/deps/cares/config/android/ares_config.h

target_dir=$MEDIR/../$ME/android-toolchain/bin
target_host=$target_dir/arm-linux-androideabi
export AR=$target_host-ar
export AS=$target_dir/llvm-as
export CC=$target_host-clang
export CXX=$target_host-clang++
export CPP=$target_host-clang++
export LINK="$target_host-clang++ -static-libstdc++"
export LD=$target_dir/llvm-link
export STRIP=$target_host-strip
export CFLAGS="-fPIE -fPIC"
export CXXFLAGS=$CFLAGS
export LDFLAGS="-pie"


# patch android-configure
F=$MEDIR/../$ME/android-configure
# - skip original configure command line
sed -i 's/"configure"/"xconfigure"/' $F
sed -i "s/--platform=android-.*/--platform=android-21 --stl=libc++ --use-llvm/" $F
cat >> $F <<EOF
export AR=$AR
export AS=$AS
export CC=$CC
export CXX=$CXX
export CPP=$CXX
export LINK="$CXX -static-libstdc++"
export LD=$LD
export STRIP=$STRIP
export CFLAGS=$CFLAGS
export CXXFLAGS=$CFLAGS
export LDFLAGS=$LDFLAGS
EOF
# - run modified configure command line (arguments and flags updated)
echo './configure --dest-cpu=$DEST_CPU --dest-os=android --without-snapshot --openssl-no-asm \' >> $F
echo "            --with-intl=none --cross-compiling --prefix=$MEDIR/../$ME/dist" >> $F
./android-configure $NDKDIR
# - delete libc++_shared.so; it is just a joke here and you can keep them
find $MEDIR/../$ME/android-toolchain -name "libc++_shared.so" | xargs rm

# gcc reprot unrecognized flag of "-m64" error
# find $MEDIR/../$ME/out/deps/openssl -name "openssl*.mk" | xargs sed -i 's/-m64//g'

F=$MEDIR/../$ME/out/node.target.mk
sed -i "s|-llog|-llog -L$NDKDIR/sources/cxx-stl/llvm-libc++/libs/armeabi -landroid_support|g" $F
# skip cctest; if want, you may need to add -lgnustl_static to cctest.target.mk
F=$MEDIR/../$ME/out/Makefile
sed -i "s|include cctest.target.mk|#include cctest.target.mk|" $F # skip cctest
sed -i "s|include deps/gtest/gtest.target.mk|#include deps/gtest/gtest.target.mk|" $F # skip gtest

F=$MEDIR/../$ME/out/deps/openssl/openssl-cli.target.mk
sed -i "s|-llog|-llog -L$NDKDIR/sources/cxx-stl/llvm-libc++/libs/armeabi -landroid_support|g" $F
F=$MEDIR/../$ME/out/deps/v8/gypfiles/torque.host.mk
sed -i "s|-lrt|-L$NDKDIR/sources/cxx-stl/llvm-libc++/libs/armeabi -landroid_support|g" $F
sed -i "s|-ldl||g" $F
# we build torque which can run on host machine and generate source files
# they are copied to $MEDIR/../$ME/.xpatch/torque-generated
# we fake the command to skip the generation and copy back files to right place
F=$MEDIR/../$ME/out/deps/v8/gypfiles/v8_torque.host.mk
sed -i "s|cmd__\(.*\)v8_gyp_v8_torque_host_run_torque.*|cmd__\1v8_gyp_v8_torque_host_run_torque = echo fake torque generated|" $F
mkdir -p $MEDIR/../$ME/out/Release/obj/gen/torque-generated
cp -r $MEDIR/../$ME/.xpatch/torque-generated/* $MEDIR/../$ME/out/Release/obj/gen/torque-generated/


# patch for non-C++11 (if you want to use gnustl, not coplete yet)
# ignore below XOF block
cat <<XOF
# patch for non-C++11
# std::to_string and std::stod
cat >> $MEDIR/../$ME/xpatch.h <<EOF

#ifndef defined_patch
#define defined_patch
#include <string>
#include <sstream>

namespace xpatch
{
    template < typename T >
    extern std::string to_string( const T& n )
    {
        std::ostringstream stm ;
        stm << n ;
        return stm.str() ;
    }

    extern double stod(std::string str)
    {
        std::stringstream ss;
        double value = 0.0;
        ss << str;
        ss >> value;
        return value;
    }
}
#endif
EOF
F=$MEDIR/../$ME/deps/v8/third_party/antlr4/runtime/Cpp/runtime/src/antlr4-common.h
cat >> $F < $MEDIR/../$ME/xpatch.h
F=$MEDIR/../$ME/deps/v8/include/v8config.h
sed -i 's/#endif.*V8CONFIG_H_//' $F
cat >> $F < $MEDIR/../$ME/xpatch.h
echo "#endif  // V8CONFIG_H_" >> $F
grep "std::to_string" $MEDIR/../$ME -r | cut -d ':' -f 1 | sort -u | xargs sed -i "s/std::to_string/xpatch::to_string/g"
F=$MEDIR/../$ME/deps/v8/src/torque/implementation-visitor.cc
sed -i "s/std::stod/xpatch::stod/" $F
F=$MEDIR/../$ME/deps/v8/third_party/antlr4/runtime/Cpp/runtime/src/tree/pattern/ParseTreePatternMatcher.cpp
sed -i "s/std::rethrow_if_nested(e);/throw e;/" $F
F=$MEDIR/../$ME/deps/v8/third_party/antlr4/runtime/Cpp/runtime/src/UnbufferedCharStream.cpp
sed -i "s/std::throw_with_nested(RuntimeException());/throw RuntimeException()/" $F
F=$MEDIR/../$ME/deps/v8/third_party/antlr4/runtime/Cpp/runtime/src/BailErrorStrategy.cpp
sed -i "s/std::rethrow_exception(/throw (" $F
sed -i "s/std::throw_with_nested(ParseCancellationException())/throw ParseCancellationException()/g" $F

# TODO: more exception_ptr related errors and
#       need alternatives ...
XOF

# add missing ares_android.h
# copy from: https://github.com/c-ares/c-ares/blob/master/ares_android.h
cat >> $MEDIR/../$ME/deps/cares/include/ares_android.h <<EOF
/* Copyright (C) 2017 by John Schember <john@nachtimwald.com>
 *
 * Permission to use, copy, modify, and distribute this
 * software and its documentation for any purpose and without
 * fee is hereby granted, provided that the above copyright
 * notice appear in all copies and that both that copyright
 * notice and this permission notice appear in supporting
 * documentation, and that the name of M.I.T. not be used in
 * advertising or publicity pertaining to distribution of the
 * software without specific, written prior permission.
 * M.I.T. makes no representations about the suitability of
 * this software for any purpose.  It is provided "as is"
 * without express or implied warranty.
 */

#ifndef __ARES_ANDROID_H__
#define __ARES_ANDROID_H__

#if defined(ANDROID) || defined(__ANDROID__)

char **ares_get_android_server_list(size_t max_servers, size_t *num_servers);
char *ares_get_android_search_domains_list(void);
void ares_library_cleanup_android(void);

#endif

#endif /* __ARES_ANDROID_H__ */
EOF

# if you meet "too many opened files" error, uncomment below line and try again
# ulimit -n 4096

make
make_install $ME


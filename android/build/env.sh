#/bin/bash

echo "Please configure this env.sh ..."
echo "  SRCTARBALL, NDKDIR, BUILD_MACHINE, ANDROID_VERSION, GCC_VERSION"
exit 1
# Then remove above echo and exit

# Prepare Environment
export ANDROID_VERSION="{----- android version: e.g. 17 =Android 4.2 -----}"
export BUILD_MACHINE="{----- build machine: lower case of uname -s -m; e.g. linux-x86_64 -----}"
export GCC_VERSION="{----- gcc version: e.g. 4.8 -----}"
export SRCTARBALL="{----- source tarball path -----}"
export NDKDIR="{----- Google Android NDK path -----}"

# example:
# export ANDROID_VERSION="23" # android 6.0
# export BUILD_MACHINE="darwin-x86_64" # build on macosx; for linux, usually "linux-x86_64"; not yet try on windows
# export GCC_VERSION="4.9"
# export SRCTARBALL="/opt"
# export NDKDIR="/toolchain/android-ndk"

export DISTBIN="bin"

function make_install() {
# $1: package name
  make install
  rm -rf ../$DISTBIN/$1
  mkdir -p ../$DISTBIN/$1
  mv dist/* ../$DISTBIN/$1/
  cd ..
  rm -rf $1
}

function fetch_source() {
# $1: package file name, e.g. vim-7.4.0001.tar.gz
# $2: source url
  test -f "$SRCTARBALL/$1" || curl -k -L -o "$SRCTARBALL/$1" "$2"
  test -f "$SRCTARBALL/$1" || exit 1
}

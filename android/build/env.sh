#/bin/bash

echo "Please configure this common.sh ..."
echo "  SRCTARBALL, NDKDIR, ANDROID_VERSION, GCC_VERSION"
exit 1
# Then remove above echo and exit

# Prepare Environment
export ANDROID_VERSION="{----- android version: e.g. 17 =Android 4.2 -----}"
export GCC_VERSION="{----- gcc version: e.g. 4.8 -----}"
export SRCTARBALL="{----- source tarball path -----}"
export NDKDIR="{----- Google Android NDK path -----}"

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

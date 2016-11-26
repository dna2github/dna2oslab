#/bin/bash

# ref: http://tiebing.blogspot.jp/2014/09/cross-compile-nginx-for-arm.html
# good method:
# - 1. ./configure with local environment
# - 2. modify objs/ngx* objs/Makefile
# - 3. load android environment and make

echo Notice: require openssl-1.0.1p, pcre-8.37, zlib-1.2.8 compiled
sleep 2

set -xe

MEDIR=$(cd `dirname $0`; pwd)
ME=nginx-1.10.2

cd $MEDIR
source env.sh

cd ..
rm -rf $ME
fetch_source $ME.tar.gz http://nginx.org/download/nginx-1.10.2.tar.gz
tar zxf $SRCTARBALL/$ME.tar.gz
cd $ME
mkdir -p dist objs

####### ./configure  --prefix=$MEDIR/../$ME/dist/ \
#######     --crossbuild="linux:android:arm-eabi" \
#######     --with-cc="gcc" --with-cpp="cpp" \
#######     --without-http_rewrite_module \
#######     --with-stream \
#######     --with-mail \
#######     --with-http_gunzip_module \
#######     --with-http_gzip_static_module \
#######     --with-http_auth_request_module \
#######     --with-http_slice_module \
#######     --with-http_realip_module \
#######     --with-http_v2_module \
#######     --with-threads \
#######     --with-select_module \
#######     --with-poll_module \
#######     --with-http_ssl_module \
#######     --with-stream_ssl_module \
#######     --with-mail_ssl_module

source $MEDIR/common.sh
cp $MEDIR/nginx/* objs

mkdir -p objs/src/{core,event,http,mail,misc,os,stream}
mkdir -p objs/src/event/modules
mkdir -p objs/src/http/{modules,v2}
mkdir -p objs/src/modules/perl
mkdir -p objs/src/os/unix

OPENSSL=openssl-1.0.1p
ZLIB=zlib-1.2.8
PCRE=pcre-8.37
OPENSSLFLAGS="-I$MEDIR/../bin/$OPENSSL/include -I$MEDIR/../bin/$OPENSSL/include/openssl -L$MEDIR/../bin/$OPENSSL/lib"
ZLIBFLAGS="-I$MEDIR/../bin/$ZLIB/include -L$MEDIR/../bin/$ZLIB/lib"
PCREFLAGS="-I$MEDIR/../bin/$PCRE/include -L$MEDIR/../bin/$PCRE/lib"

sed -i "s|^CC =.*$|CC = $CC|" objs/Makefile
sed -i "s|^CFLAGS =.*$|CFLAGS = -pipe -O -Wall $CFLAGS $OPENSSLFLAGS $ZLIBFLAGS $PCREFLAGS $LDFLAGS|" objs/Makefile
sed -i "s|^CPP =.*$|CPP = $CPP|" objs/Makefile
sed -i "s|^LINK =.*$|LINK = $CC --sysroot=$ANDROID|" objs/Makefile
sed -i "s|^PREFIX=.*$|PREFIX = $MEDIR/../$ME/dist|" objs/Makefile
sed -i "s|^OPENSSL=.*$|OPENSSL=$OPENSSL|" objs/Makefile
sed -i "s|^ZLIB=.*$|ZLIB=$ZLIB|" objs/Makefile
sed -i "s|^PCRE=.*$|PCRE=$PCRE|" objs/Makefile
sed -i "s|^#include <glob.h>||" src/os/unix/ngx_posix_config.h
sed -i "s|^#include <crypt.h>||" src/os/unix/ngx_posix_config.h
# if want more IOV_MAX, default is 16
#sed -i "s|^#define IOV_MAX|64|" src/os/unix/ngx_posix_config.h
sed -i "s|in_port_t|uint16_t|g" src/core/ngx_inet.h
sed -i "s|in_port_t|uint16_t|g" src/core/ngx_inet.c
sed -i "s|in_port_t|uint16_t|g" src/event/ngx_event_openssl_stapling.c
sed -i "s|in_port_t|uint16_t|g" src/http/ngx_http_upstream.h
sed -i "s|in_port_t|uint16_t|g" src/http/ngx_http_core_module.h
sed -i "s|in_port_t|uint16_t|g" src/http/ngx_http.c
sed -i "s|in_port_t|uint16_t|g" src/http/modules/ngx_http_proxy_module.c
sed -i "s|in_port_t|uint16_t|g" src/mail/ngx_mail.h
sed -i "s|in_port_t|uint16_t|g" src/mail/ngx_mail.c
sed -i "s|in_port_t|uint16_t|g" src/mail/ngx_mail_core_module.c
sed -i "s|in_port_t|uint16_t|g" src/mail/ngx_mail_auth_http_module.c
sed -i "s|in_port_t|uint16_t|g" src/stream/ngx_stream_upstream.h
sed -i "s|in_port_t|uint16_t|g" src/stream/ngx_stream.h
sed -i "s|in_port_t|uint16_t|g" src/stream/ngx_stream.c
sed -i "s|in_port_t|uint16_t|g" src/stream/ngx_stream_core_module.c

# disable glob, no fuzzy file name in conf file like "hello*"
sed -i "s| glob_t | ngx_str_t * |" src/os/unix/ngx_files.h
sed -n '1,702p' src/os/unix/ngx_files.c > src/os/unix/ngx_files.c.fix
echo 'ngx_int_t ngx_open_glob(ngx_glob_t *gl) { return NGX_OK;}' >> src/os/unix/ngx_files.c.fix
echo 'ngx_int_t ngx_read_glob(ngx_glob_t *gl, ngx_str_t *name) { gl->pglob = name; return NGX_OK;}' >> src/os/unix/ngx_files.c.fix
echo 'void ngx_close_glob(ngx_glob_t *gl) {gl->pglob = 0;}' >> src/os/unix/ngx_files.c.fix
sed -n '757,$p' src/os/unix/ngx_files.c >> src/os/unix/ngx_files.c.fix
mv src/os/unix/ngx_files.c src/os/unix/ngx_files.c.bak
mv src/os/unix/ngx_files.c.fix src/os/unix/ngx_files.c

# no crypt; use the one in openssl (DES_crypt)
echo "#include <openssl/ssl.h>" > src/os/unix/ngx_user.c.fix
echo "#ifndef crypt" >> src/os/unix/ngx_user.c.fix
echo "#define crypt(c, k) DES_crypt((c), (k))" >> src/os/unix/ngx_user.c.fix
echo "#endif" >> src/os/unix/ngx_user.c.fix
cat src/os/unix/ngx_user.c >> src/os/unix/ngx_user.c.fix
mv src/os/unix/ngx_user.c src/os/unix/ngx_user.c.bak
mv src/os/unix/ngx_user.c.fix src/os/unix/ngx_user.c

make -f objs/Makefile
make -f objs/Makefile install
rm -rf ../bin/$ME
mv dist ../bin/$ME
cd ..
rm -rf $ME


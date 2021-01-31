#/bin/bash
set -xe

MEDIR=$(cd `dirname $0`; pwd)
ME=nginx-1.18.0
PCRE=pcre-8.44
OPENSSL=openssl-1.1.1i
ZLIB=zlib-1.2.11

cd $MEDIR
source env.sh

cd ..
rm -rf $ME
fetch_source $ME.tar.gz http://nginx.org/download/nginx-1.18.0.tar.gz
fetch_source $PCRE.tar.gz http://downloads.sourceforge.net/project/pcre/pcre/8.44/pcre-8.44.tar.gz
fetch_source $OPENSSL.tar.gz https://www.openssl.org/source/openssl-1.1.1i.tar.gz
fetch_source $ZLIB.tar.gz http://zlib.net/zlib-1.2.11.tar.gz
tar zxf $ENVSRCTARBALL/$ME.tar.gz
cd $ME
mkdir -p 3rd
cd 3rd
tar zxf $ENVSRCTARBALL/$PCRE.tar.gz
tar zxf $ENVSRCTARBALL/$OPENSSL.tar.gz
tar zxf $ENVSRCTARBALL/$ZLIB.tar.gz
cd ..
mkdir -p dist

if [ ! -d $MEDIR/../$ENVDISTBIN/$PCRE ]; then
   bash $MEDIR/$PCRE.sh
fi
if [ ! -d $MEDIR/../$ENVDISTBIN/$ZLIB ]; then
   bash $MEDIR/$ZLIB.sh
fi

grep "found but" . -r | cut -d ':' -f 1 | sort -u | xargs sed -i 's|.*NGX_AUTOTEST >> .*|if [ 1 == 1 ]; then|g'
sed -i 's|ngx_size=`$NGX_AUTOTEST`|ngx_size=4|' auto/types/sizeof
sed -i 's|#include <crypt.h>||' src/os/unix/ngx_linux_config.h

# EPOLL value ref: /sysroot/usr/include/linux/eventpoll.h
sed -i 's/EPOLLIN[|]EPOLLRDHUP/0x00000001|0x00000010/g' src/event/ngx_event.h
sed -i 's|EPOLLOUT|0x00000004|g' src/event/ngx_event.h
sed -i 's|EPOLLET|(1U << 31)|g' src/event/ngx_event.h
sed -i 's|#if (NGX_READ_EVENT != EPOLLIN[|]EPOLLRDHUP)|#if 0|' src/event/modules/ngx_epoll_module.c
sed -i 's|#if (NGX_WRITE_EVENT != EPOLLOUT)|#if 0|g' src/event/modules/ngx_epoll_module.c

cat > .shit.patch <<EOF
// ref: https://android.googlesource.com/platform/bionic/+/master/libc/include/glob.h
EOF
cat $MEDIR/glob/glob.h >> .shit.patch
cat src/os/unix/ngx_files.c >> .shit.patch
mv .shit.patch src/os/unix/ngx_files.c
cat > src/os/unix/ngx_user.c <<EOF
#include <ngx_config.h>
#include <ngx_core.h>

#if (NGX_CRYPT)
ngx_int_t
ngx_libc_crypt(ngx_pool_t *pool, u_char *key, u_char *salt, u_char **encrypted)
{
    return NGX_ERROR;
}
#endif /* NGX_CRYPT */
EOF

# openssl use CROSS_COMPILE as CC
XCFLAGS=$CROSS_COMPILE
unset CROSS_COMPILE
export CFLAGS="$CFLAGS -I`pwd`/../dist/$PCRE/include -I`pwd`/../dist/$ZLIB/include"
export LDFLAGS="$LDFLAGS -L`pwd`/../dist/$PCRE/lib -L`pwd`/../dist/$ZLIB/lib"


# pcre and zlib is needed for feature check but it does not compile pcre and zlib
# it must be related to NGX_AUTOTEST where we disable all binary execution
./configure --prefix=$MEDIR/../$ME/dist/ \
   --with-openssl=`pwd`/3rd/$OPENSSL --with-openssl-opt="no-asm -fPIC" \
   --with-pcre=`pwd/3rd/$PCRE`  --with-pcre-opt="$XCFLAGS" \
   --with-zlib=`pwd/3rd/$ZLIB`  --with-zlib-opt="$XCFLAGS" \
   --with-poll_module \
   --with-http_ssl_module --with-http_v2_module --with-http_auth_request_module \
   --with-http_gunzip_module --with-http_gzip_static_module \
   --with-stream=dynamic --with-stream_ssl_module \
   --with-mail=dynamic --with-mail_ssl_module \
   --with-compat

sed -i 's|#define.*NGX_SYS_NERR.*|#define NGX_SYS_NERR 135|' objs/ngx_auto_config.h
cat >> objs/ngx_auto_config.h <<EOF
#ifndef NGX_PCRE
#define NGX_PCRE 1
#endif
EOF
sed -i 's|#define NGX_HAVE_SCHED_SETAFFINITY.*||' objs/ngx_auto_config.h
sed -i 's|#define NGX_HAVE_CPUSET_SETAFFINITY.*||' objs/ngx_auto_config.h

$CC -I$MEDIR/glob -c -o __glob.o $MEDIR/glob/glob.c
sed -i "s|\(.*\) -lz|__glob.o \1 `pwd`/../dist/$PCRE/lib/libpcre.a `pwd`/../dist/$ZLIB/lib/libz.a|" objs/Makefile

make
make_install $ME

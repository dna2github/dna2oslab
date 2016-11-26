#/bin/bash

echo "================================================="
echo "pleaes compile pcre-8.37 and openssl-1.0.1p first"
echo "================================================="
sleep 1

set -xe

MEDIR=$(cd `dirname $0`; pwd)
ME=nginx-1.9.5

cd $MEDIR
source common.sh

cd ..
rm -rf $ME
fetch_source $ME.tar.gz http://nginx.org/download/nginx-1.9.5.tar.gz
tar zxf $SRCTARBALL/$ME.tar.gz
cd $ME
mkdir -p dist

mkdir -p objs/src/{core,mail,stream}
mkdir -p objs/src/http/{modules,v2}
mkdir -p objs/src/event/modules
mkdir -p objs/src/os/unix
cp $MEDIR/nginx/ngx_auto_config.h $MEDIR/nginx/ngx_auto_headers.h $MEDIR/nginx/ngx_modules.c objs/
cp $ANDROID/lib/*.o ./

sed -i 's|struct group.*grp;|int grp;|g' src/core/nginx.c
sed -i 's|struct passwd.*pwd;|int pwd;|g' src/core/nginx.c
sed -i 's|pwd = getpwnam.*|pwd = 1000;|g' src/core/nginx.c
sed -i 's|grp = getgrnam.*|grp = 1000;|g' src/core/nginx.c
sed -i 's|pwd->pw_uid|pwd|g' src/core/nginx.c
sed -i 's|grp->gr_gid|grp|g' src/core/nginx.c
sed -i 's|.*<glob.h>.*||g' src/os/unix/ngx_linux_config.h
sed -i 's|.*<glob.h>.*||g' src/os/unix/ngx_linux_config.h
sed -i 's|n = glob.*|n = 1; // always return error|g' src/os/unix/ngx_files.c
sed -i 's|.*gl->pglob.*||g' src/os/unix/ngx_files.c
sed -i 's|.*globfree.*||g' src/os/unix/ngx_files.c
sed -i 's|glob_t.*pglob|unsigned int pglob|g' src/os/unix/ngx_files.h
sed -i 's|.*<crypt.h>.*||g' src/os/unix/ngx_linux_config.h
sed -i 's|in_port_t|uint16_t |g' src/core/ngx_inet.c
sed -i 's|in_port_t|uint16_t |g' src/core/ngx_inet.h
sed -i 's|in_port_t|uint16_t |g' src/event/ngx_event_openssl_stapling.c
sed -i 's|in_port_t|uint16_t |g' src/http/ngx_http_upstream.h
sed -i 's|in_port_t|uint16_t |g' src/http/ngx_http_core_module.h
sed -i 's|in_port_t|uint16_t |g' src/http/ngx_http.c
sed -i 's|in_port_t|uint16_t |g' src/http/modules/ngx_http_proxy_module.c
sed -i 's|in_port_t|uint16_t |g' src/mail/ngx_mail_core_module.c
sed -i 's|in_port_t|uint16_t |g' src/mail/ngx_mail.h
sed -i 's|in_port_t|uint16_t |g' src/mail/ngx_mail.c
sed -i 's|in_port_t|uint16_t |g' src/mail/ngx_mail_auth_http_module.c
sed -i 's|in_port_t|uint16_t |g' src/stream/ngx_stream_upstream.h
sed -i 's|in_port_t|uint16_t |g' src/stream/ngx_stream_upstream.c
sed -i 's|in_port_t|uint16_t |g' src/stream/ngx_stream.h
sed -i 's|in_port_t|uint16_t |g' src/stream/ngx_stream.c
sed -i 's|in_port_t|uint16_t |g' src/stream/ngx_stream_core_module.c
sed -i 's|SO_REUSEPORT|0x0200|g' src/core/ngx_connection.c
sed -i 's|AT_EMPTY_PATH|0x2000|g' src/core/ngx_open_file_cache.c
sed -i 's|O_PATH|0x1000000|g' src/os/unix/ngx_files.h
sed -i 's|POSIX_FADV_SEQUENTIAL|2|g' src/os/unix/ngx_files.c
sed -i 's|IOV_MAX|1024|g' src/os/unix/ngx_files.c
sed -i 's|IOV_MAX|1024|g' src/os/unix/ngx_os.h
sed -i 's|IOV_MAX|1024|g' src/os/unix/ngx_readv_chain.c
sed -i 's|SOCK_NONBLOCK|0x0080|g' src/event/ngx_event_accept.c # SOCK_NONBLOCK=O_NONBLOCK=0x0080

CFLAGS="-O -W -Wall -Wpointer-arith -Wno-unused-parameter -g -fPIE -pie -fvisibility=default"
PCRE="$MEDIR/../bin/pcre-8.37"
OPENSSL="$MEDIR/../bin/openssl-1.0.1p"
PCREDIR="-I $PCRE/include"
OPENSSLDIR="-I $OPENSSL/include -I $OPENSSL/include/openssl"
PCREDIR_LIB="-l$PCRE/lib/libpcre.a"
OPENSSLDIR_LIB="-l$OPENSSL/lib/libssl.a -l$OPENSSL/lib/libcrypto.a"
BASICDIR="-I src/core -I src/event -I src/event/modules -I src/os/unix -I $ANDROID/include"

$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/core/nginx.o src/core/nginx.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/core/ngx_log.o src/core/ngx_log.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/core/ngx_palloc.o src/core/ngx_palloc.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/core/ngx_array.o src/core/ngx_array.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/core/ngx_list.o src/core/ngx_list.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/core/ngx_hash.o src/core/ngx_hash.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/core/ngx_buf.o src/core/ngx_buf.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/core/ngx_queue.o src/core/ngx_queue.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/core/ngx_output_chain.o src/core/ngx_output_chain.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/core/ngx_string.o src/core/ngx_string.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/core/ngx_parse.o src/core/ngx_parse.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/core/ngx_parse_time.o src/core/ngx_parse_time.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/core/ngx_inet.o src/core/ngx_inet.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/core/ngx_file.o src/core/ngx_file.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/core/ngx_crc32.o src/core/ngx_crc32.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/core/ngx_murmurhash.o src/core/ngx_murmurhash.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/core/ngx_md5.o src/core/ngx_md5.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/core/ngx_rbtree.o src/core/ngx_rbtree.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/core/ngx_radix_tree.o src/core/ngx_radix_tree.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/core/ngx_slab.o src/core/ngx_slab.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/core/ngx_times.o src/core/ngx_times.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/core/ngx_shmtx.o src/core/ngx_shmtx.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/core/ngx_connection.o src/core/ngx_connection.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/core/ngx_cycle.o src/core/ngx_cycle.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/core/ngx_spinlock.o src/core/ngx_spinlock.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/core/ngx_rwlock.o src/core/ngx_rwlock.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/core/ngx_cpuinfo.o src/core/ngx_cpuinfo.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/core/ngx_conf_file.o src/core/ngx_conf_file.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/core/ngx_resolver.o src/core/ngx_resolver.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/core/ngx_open_file_cache.o src/core/ngx_open_file_cache.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/core/ngx_crypt.o src/core/ngx_crypt.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/core/ngx_proxy_protocol.o src/core/ngx_proxy_protocol.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/core/ngx_syslog.o src/core/ngx_syslog.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/event/ngx_event.o src/event/ngx_event.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/event/ngx_event_timer.o src/event/ngx_event_timer.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/event/ngx_event_posted.o src/event/ngx_event_posted.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/event/ngx_event_accept.o src/event/ngx_event_accept.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/event/ngx_event_connect.o src/event/ngx_event_connect.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/event/ngx_event_pipe.o src/event/ngx_event_pipe.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/os/unix/ngx_time.o src/os/unix/ngx_time.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/os/unix/ngx_errno.o src/os/unix/ngx_errno.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/os/unix/ngx_alloc.o src/os/unix/ngx_alloc.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/os/unix/ngx_files.o src/os/unix/ngx_files.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/os/unix/ngx_socket.o src/os/unix/ngx_socket.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/os/unix/ngx_recv.o src/os/unix/ngx_recv.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/os/unix/ngx_readv_chain.o src/os/unix/ngx_readv_chain.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/os/unix/ngx_udp_recv.o src/os/unix/ngx_udp_recv.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/os/unix/ngx_send.o src/os/unix/ngx_send.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/os/unix/ngx_writev_chain.o src/os/unix/ngx_writev_chain.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/os/unix/ngx_channel.o src/os/unix/ngx_channel.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/os/unix/ngx_shmem.o src/os/unix/ngx_shmem.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/os/unix/ngx_process.o src/os/unix/ngx_process.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/os/unix/ngx_daemon.o src/os/unix/ngx_daemon.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/os/unix/ngx_setaffinity.o src/os/unix/ngx_setaffinity.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/os/unix/ngx_setproctitle.o src/os/unix/ngx_setproctitle.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/os/unix/ngx_posix_init.o src/os/unix/ngx_posix_init.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/os/unix/ngx_user.o src/os/unix/ngx_user.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/os/unix/ngx_process_cycle.o src/os/unix/ngx_process_cycle.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/os/unix/ngx_linux_init.o src/os/unix/ngx_linux_init.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/event/modules/ngx_epoll_module.o src/event/modules/ngx_epoll_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/os/unix/ngx_linux_sendfile_chain.o src/os/unix/ngx_linux_sendfile_chain.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/event/ngx_event_openssl.o src/event/ngx_event_openssl.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/event/ngx_event_openssl_stapling.o src/event/ngx_event_openssl_stapling.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/src/core/ngx_regex.o src/core/ngx_regex.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/ngx_http.o src/http/ngx_http.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/ngx_http_core_module.o src/http/ngx_http_core_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/ngx_http_special_response.o src/http/ngx_http_special_response.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/ngx_http_request.o src/http/ngx_http_request.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/ngx_http_parse.o src/http/ngx_http_parse.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/ngx_http_header_filter_module.o src/http/ngx_http_header_filter_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/ngx_http_write_filter_module.o src/http/ngx_http_write_filter_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/ngx_http_copy_filter_module.o src/http/ngx_http_copy_filter_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/modules/ngx_http_log_module.o src/http/modules/ngx_http_log_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/ngx_http_request_body.o src/http/ngx_http_request_body.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/ngx_http_variables.o src/http/ngx_http_variables.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/ngx_http_script.o src/http/ngx_http_script.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/ngx_http_upstream.o src/http/ngx_http_upstream.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/ngx_http_upstream_round_robin.o src/http/ngx_http_upstream_round_robin.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/modules/ngx_http_static_module.o src/http/modules/ngx_http_static_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/modules/ngx_http_index_module.o src/http/modules/ngx_http_index_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/modules/ngx_http_chunked_filter_module.o src/http/modules/ngx_http_chunked_filter_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/modules/ngx_http_range_filter_module.o src/http/modules/ngx_http_range_filter_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/modules/ngx_http_headers_filter_module.o src/http/modules/ngx_http_headers_filter_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/modules/ngx_http_not_modified_filter_module.o src/http/modules/ngx_http_not_modified_filter_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/ngx_http_file_cache.o src/http/ngx_http_file_cache.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/ngx_http_postpone_filter_module.o src/http/ngx_http_postpone_filter_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/modules/ngx_http_ssi_filter_module.o src/http/modules/ngx_http_ssi_filter_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/modules/ngx_http_charset_filter_module.o src/http/modules/ngx_http_charset_filter_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/modules/ngx_http_userid_filter_module.o src/http/modules/ngx_http_userid_filter_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/v2/ngx_http_v2.o src/http/v2/ngx_http_v2.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/v2/ngx_http_v2_table.o src/http/v2/ngx_http_v2_table.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/v2/ngx_http_v2_huff_decode.o src/http/v2/ngx_http_v2_huff_decode.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/v2/ngx_http_v2_huff_encode.o src/http/v2/ngx_http_v2_huff_encode.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/v2/ngx_http_v2_module.o src/http/v2/ngx_http_v2_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/v2/ngx_http_v2_filter_module.o src/http/v2/ngx_http_v2_filter_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/modules/ngx_http_autoindex_module.o src/http/modules/ngx_http_autoindex_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/modules/ngx_http_random_index_module.o src/http/modules/ngx_http_random_index_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/modules/ngx_http_auth_request_module.o src/http/modules/ngx_http_auth_request_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/modules/ngx_http_access_module.o src/http/modules/ngx_http_access_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/modules/ngx_http_limit_conn_module.o src/http/modules/ngx_http_limit_conn_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/modules/ngx_http_limit_req_module.o src/http/modules/ngx_http_limit_req_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/modules/ngx_http_realip_module.o src/http/modules/ngx_http_realip_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/modules/ngx_http_geo_module.o src/http/modules/ngx_http_geo_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/modules/ngx_http_map_module.o src/http/modules/ngx_http_map_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/modules/ngx_http_split_clients_module.o src/http/modules/ngx_http_split_clients_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/modules/ngx_http_referer_module.o src/http/modules/ngx_http_referer_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/modules/ngx_http_rewrite_module.o src/http/modules/ngx_http_rewrite_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/modules/ngx_http_ssl_module.o src/http/modules/ngx_http_ssl_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/modules/ngx_http_proxy_module.o src/http/modules/ngx_http_proxy_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/modules/ngx_http_fastcgi_module.o src/http/modules/ngx_http_fastcgi_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/modules/ngx_http_uwsgi_module.o src/http/modules/ngx_http_uwsgi_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/modules/ngx_http_scgi_module.o src/http/modules/ngx_http_scgi_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/modules/ngx_http_memcached_module.o src/http/modules/ngx_http_memcached_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/modules/ngx_http_empty_gif_module.o src/http/modules/ngx_http_empty_gif_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/modules/ngx_http_browser_module.o src/http/modules/ngx_http_browser_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/modules/ngx_http_secure_link_module.o src/http/modules/ngx_http_secure_link_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/modules/ngx_http_upstream_hash_module.o src/http/modules/ngx_http_upstream_hash_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/modules/ngx_http_upstream_ip_hash_module.o src/http/modules/ngx_http_upstream_ip_hash_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/modules/ngx_http_upstream_least_conn_module.o src/http/modules/ngx_http_upstream_least_conn_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/modules/ngx_http_upstream_keepalive_module.o src/http/modules/ngx_http_upstream_keepalive_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/modules/ngx_http_upstream_zone_module.o src/http/modules/ngx_http_upstream_zone_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/http -I src/http/modules -I src/http/v2 -o objs/src/http/modules/ngx_http_stub_status_module.o src/http/modules/ngx_http_stub_status_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/mail -o objs/src/mail/ngx_mail.o src/mail/ngx_mail.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/mail -o objs/src/mail/ngx_mail_core_module.o src/mail/ngx_mail_core_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/mail -o objs/src/mail/ngx_mail_handler.o src/mail/ngx_mail_handler.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/mail -o objs/src/mail/ngx_mail_parse.o src/mail/ngx_mail_parse.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/mail -o objs/src/mail/ngx_mail_ssl_module.o src/mail/ngx_mail_ssl_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/mail -o objs/src/mail/ngx_mail_pop3_module.o src/mail/ngx_mail_pop3_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/mail -o objs/src/mail/ngx_mail_pop3_handler.o src/mail/ngx_mail_pop3_handler.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/mail -o objs/src/mail/ngx_mail_imap_module.o src/mail/ngx_mail_imap_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/mail -o objs/src/mail/ngx_mail_imap_handler.o src/mail/ngx_mail_imap_handler.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/mail -o objs/src/mail/ngx_mail_smtp_module.o src/mail/ngx_mail_smtp_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/mail -o objs/src/mail/ngx_mail_smtp_handler.o src/mail/ngx_mail_smtp_handler.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/mail -o objs/src/mail/ngx_mail_auth_http_module.o src/mail/ngx_mail_auth_http_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/mail -o objs/src/mail/ngx_mail_proxy_module.o src/mail/ngx_mail_proxy_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/stream -o objs/src/stream/ngx_stream.o src/stream/ngx_stream.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/stream -o objs/src/stream/ngx_stream_handler.o src/stream/ngx_stream_handler.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/stream -o objs/src/stream/ngx_stream_core_module.o src/stream/ngx_stream_core_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/stream -o objs/src/stream/ngx_stream_proxy_module.o src/stream/ngx_stream_proxy_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/stream -o objs/src/stream/ngx_stream_upstream.o src/stream/ngx_stream_upstream.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/stream -o objs/src/stream/ngx_stream_upstream_round_robin.o src/stream/ngx_stream_upstream_round_robin.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/stream -o objs/src/stream/ngx_stream_ssl_module.o src/stream/ngx_stream_ssl_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/stream -o objs/src/stream/ngx_stream_limit_conn_module.o src/stream/ngx_stream_limit_conn_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/stream -o objs/src/stream/ngx_stream_access_module.o src/stream/ngx_stream_access_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/stream -o objs/src/stream/ngx_stream_upstream_hash_module.o src/stream/ngx_stream_upstream_hash_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/stream -o objs/src/stream/ngx_stream_upstream_least_conn_module.o src/stream/ngx_stream_upstream_least_conn_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -I src/stream -o objs/src/stream/ngx_stream_upstream_zone_module.o src/stream/ngx_stream_upstream_zone_module.c
$CC -c -pipe $CFLAGS $BASICDIR $PCREDIR $OPENSSLDIR -I objs -o objs/ngx_modules.o objs/ngx_modules.c
$CC -o objs/nginx -rdynamic -fPIE -pie \
objs/src/core/nginx.o \
objs/src/core/ngx_log.o \
objs/src/core/ngx_palloc.o \
objs/src/core/ngx_array.o \
objs/src/core/ngx_list.o \
objs/src/core/ngx_hash.o \
objs/src/core/ngx_buf.o \
objs/src/core/ngx_queue.o \
objs/src/core/ngx_output_chain.o \
objs/src/core/ngx_string.o \
objs/src/core/ngx_parse.o \
objs/src/core/ngx_parse_time.o \
objs/src/core/ngx_inet.o \
objs/src/core/ngx_file.o \
objs/src/core/ngx_crc32.o \
objs/src/core/ngx_murmurhash.o \
objs/src/core/ngx_md5.o \
objs/src/core/ngx_rbtree.o \
objs/src/core/ngx_radix_tree.o \
objs/src/core/ngx_slab.o \
objs/src/core/ngx_times.o \
objs/src/core/ngx_shmtx.o \
objs/src/core/ngx_connection.o \
objs/src/core/ngx_cycle.o \
objs/src/core/ngx_spinlock.o \
objs/src/core/ngx_rwlock.o \
objs/src/core/ngx_cpuinfo.o \
objs/src/core/ngx_conf_file.o \
objs/src/core/ngx_resolver.o \
objs/src/core/ngx_open_file_cache.o \
objs/src/core/ngx_crypt.o \
objs/src/core/ngx_proxy_protocol.o \
objs/src/core/ngx_syslog.o \
objs/src/event/ngx_event.o \
objs/src/event/ngx_event_timer.o \
objs/src/event/ngx_event_posted.o \
objs/src/event/ngx_event_accept.o \
objs/src/event/ngx_event_connect.o \
objs/src/event/ngx_event_pipe.o \
objs/src/os/unix/ngx_time.o \
objs/src/os/unix/ngx_errno.o \
objs/src/os/unix/ngx_alloc.o \
objs/src/os/unix/ngx_files.o \
objs/src/os/unix/ngx_socket.o \
objs/src/os/unix/ngx_recv.o \
objs/src/os/unix/ngx_readv_chain.o \
objs/src/os/unix/ngx_udp_recv.o \
objs/src/os/unix/ngx_send.o \
objs/src/os/unix/ngx_writev_chain.o \
objs/src/os/unix/ngx_channel.o \
objs/src/os/unix/ngx_shmem.o \
objs/src/os/unix/ngx_process.o \
objs/src/os/unix/ngx_daemon.o \
objs/src/os/unix/ngx_setaffinity.o \
objs/src/os/unix/ngx_setproctitle.o \
objs/src/os/unix/ngx_posix_init.o \
objs/src/os/unix/ngx_user.o \
objs/src/os/unix/ngx_process_cycle.o \
objs/src/os/unix/ngx_linux_init.o \
objs/src/event/modules/ngx_epoll_module.o \
objs/src/os/unix/ngx_linux_sendfile_chain.o \
objs/src/event/ngx_event_openssl.o \
objs/src/event/ngx_event_openssl_stapling.o \
objs/src/core/ngx_regex.o \
objs/src/http/ngx_http.o \
objs/src/http/ngx_http_core_module.o \
objs/src/http/ngx_http_special_response.o \
objs/src/http/ngx_http_request.o \
objs/src/http/ngx_http_parse.o \
objs/src/http/ngx_http_header_filter_module.o \
objs/src/http/ngx_http_write_filter_module.o \
objs/src/http/ngx_http_copy_filter_module.o \
objs/src/http/modules/ngx_http_log_module.o \
objs/src/http/ngx_http_request_body.o \
objs/src/http/ngx_http_variables.o \
objs/src/http/ngx_http_script.o \
objs/src/http/ngx_http_upstream.o \
objs/src/http/ngx_http_upstream_round_robin.o \
objs/src/http/modules/ngx_http_static_module.o \
objs/src/http/modules/ngx_http_index_module.o \
objs/src/http/modules/ngx_http_chunked_filter_module.o \
objs/src/http/modules/ngx_http_range_filter_module.o \
objs/src/http/modules/ngx_http_headers_filter_module.o \
objs/src/http/modules/ngx_http_not_modified_filter_module.o \
objs/src/http/ngx_http_file_cache.o \
objs/src/http/ngx_http_postpone_filter_module.o \
objs/src/http/modules/ngx_http_ssi_filter_module.o \
objs/src/http/modules/ngx_http_charset_filter_module.o \
objs/src/http/modules/ngx_http_userid_filter_module.o \
objs/src/http/v2/ngx_http_v2.o \
objs/src/http/v2/ngx_http_v2_table.o \
objs/src/http/v2/ngx_http_v2_huff_decode.o \
objs/src/http/v2/ngx_http_v2_huff_encode.o \
objs/src/http/v2/ngx_http_v2_module.o \
objs/src/http/v2/ngx_http_v2_filter_module.o \
objs/src/http/modules/ngx_http_autoindex_module.o \
objs/src/http/modules/ngx_http_random_index_module.o \
objs/src/http/modules/ngx_http_auth_request_module.o \
objs/src/http/modules/ngx_http_access_module.o \
objs/src/http/modules/ngx_http_limit_conn_module.o \
objs/src/http/modules/ngx_http_limit_req_module.o \
objs/src/http/modules/ngx_http_realip_module.o \
objs/src/http/modules/ngx_http_geo_module.o \
objs/src/http/modules/ngx_http_map_module.o \
objs/src/http/modules/ngx_http_split_clients_module.o \
objs/src/http/modules/ngx_http_referer_module.o \
objs/src/http/modules/ngx_http_rewrite_module.o \
objs/src/http/modules/ngx_http_ssl_module.o \
objs/src/http/modules/ngx_http_proxy_module.o \
objs/src/http/modules/ngx_http_fastcgi_module.o \
objs/src/http/modules/ngx_http_uwsgi_module.o \
objs/src/http/modules/ngx_http_scgi_module.o \
objs/src/http/modules/ngx_http_memcached_module.o \
objs/src/http/modules/ngx_http_empty_gif_module.o \
objs/src/http/modules/ngx_http_browser_module.o \
objs/src/http/modules/ngx_http_secure_link_module.o \
objs/src/http/modules/ngx_http_upstream_hash_module.o \
objs/src/http/modules/ngx_http_upstream_ip_hash_module.o \
objs/src/http/modules/ngx_http_upstream_least_conn_module.o \
objs/src/http/modules/ngx_http_upstream_keepalive_module.o \
objs/src/http/modules/ngx_http_upstream_zone_module.o \
objs/src/http/modules/ngx_http_stub_status_module.o \
objs/src/mail/ngx_mail.o \
objs/src/mail/ngx_mail_core_module.o \
objs/src/mail/ngx_mail_handler.o \
objs/src/mail/ngx_mail_parse.o \
objs/src/mail/ngx_mail_ssl_module.o \
objs/src/mail/ngx_mail_pop3_module.o \
objs/src/mail/ngx_mail_pop3_handler.o \
objs/src/mail/ngx_mail_imap_module.o \
objs/src/mail/ngx_mail_imap_handler.o \
objs/src/mail/ngx_mail_smtp_module.o \
objs/src/mail/ngx_mail_smtp_handler.o \
objs/src/mail/ngx_mail_auth_http_module.o \
objs/src/mail/ngx_mail_proxy_module.o \
objs/src/stream/ngx_stream.o \
objs/src/stream/ngx_stream_handler.o \
objs/src/stream/ngx_stream_core_module.o \
objs/src/stream/ngx_stream_proxy_module.o \
objs/src/stream/ngx_stream_upstream.o \
objs/src/stream/ngx_stream_upstream_round_robin.o \
objs/src/stream/ngx_stream_ssl_module.o \
objs/src/stream/ngx_stream_limit_conn_module.o \
objs/src/stream/ngx_stream_access_module.o \
objs/src/stream/ngx_stream_upstream_hash_module.o \
objs/src/stream/ngx_stream_upstream_least_conn_module.o \
objs/src/stream/ngx_stream_upstream_zone_module.o \
objs/ngx_modules.o \
-ldl -lz $PCREDIR_LIB $OPENSSLDIR_LIB -L $ANDROID/lib

mkdir -p dist/{sbin,conf,html,logs,client_body_temp,fastcgi_temp,proxy_temp,scgi_temp,uwsgi_temp}
cp objs/nginx dist/sbin/
cp conf/* dist/conf/
rm -rf $MEDIR/../bin/$ME
mv dist $MEDIR/../bin/$ME
cd ..
rm -rf $ME

#define NGX_CONFIGURE " --prefix=/root/nginx-1.10.2/dist/ --crossbuild=android:arm-eabi --with-cc=gcc --with-cpp=cpp --without-http_rewrite_module --with-stream --with-mail --http-scgi-temp-path=./scgi_temp --http-uwsgi-temp-path=./uwsgi_temp --http-fastcgi-temp-path=./fastcgi_temp --http-proxy-temp-path=./proxy_temp --http-client-body-temp-path=./client_body_temp --http-log-path=./logs --with-http_gunzip_module --with-http_gzip_static_module --with-http_auth_request_module --with-http_slice_module --with-http_realip_module --with-http_v2_module --with-threads --with-select_module --with-poll_module --sbin-path=./sbin --conf-path=./conf --error-log-path=./logs --pid-path=./run --lock-path=./run --with-http_ssl_module --with-stream_ssl_module --with-mail_ssl_module --with-openssl=/root/nginx-1.10.2/deps/openssl-1.0.1p --with-pcre=/root/nginx-1.10.2/deps/pcre-8.37 --with-zlib=/root/nginx-1.10.2/deps/zlib-1.2.8"

#ifndef NGX_COMPILER
#define NGX_COMPILER  "Google Native Development Kits - gcc"
#endif


#ifndef NGX_HAVE_GCC_ATOMIC
#define NGX_HAVE_GCC_ATOMIC  1
#endif


#ifndef NGX_HAVE_C99_VARIADIC_MACROS
#define NGX_HAVE_C99_VARIADIC_MACROS  1
#endif


#ifndef NGX_HAVE_GCC_VARIADIC_MACROS
#define NGX_HAVE_GCC_VARIADIC_MACROS  1
#endif


#ifndef NGX_HAVE_GCC_BSWAP64
#define NGX_HAVE_GCC_BSWAP64  1
#endif


#ifndef NGX_ALIGNMENT
#define NGX_ALIGNMENT  16
#endif


#ifndef NGX_CPU_CACHE_LINE
#define NGX_CPU_CACHE_LINE  32
#endif


#define NGX_KQUEUE_UDATA_T  (void *)


#ifndef NGX_HAVE_POSIX_FADVISE
#define NGX_HAVE_POSIX_FADVISE  1
#endif


#ifndef NGX_HAVE_STATVFS
#define NGX_HAVE_STATVFS  1
#endif


#ifndef NGX_HAVE_SCHED_YIELD
#define NGX_HAVE_SCHED_YIELD  1
#endif


#ifndef NGX_HAVE_REUSEPORT
#define NGX_HAVE_REUSEPORT  1
#endif


#ifndef NGX_HAVE_IP_PKTINFO
#define NGX_HAVE_IP_PKTINFO  1
#endif


#ifndef NGX_HAVE_IPV6_RECVPKTINFO
#define NGX_HAVE_IPV6_RECVPKTINFO  1
#endif


#ifndef NGX_HAVE_DEFERRED_ACCEPT
#define NGX_HAVE_DEFERRED_ACCEPT  1
#endif


#ifndef NGX_HAVE_KEEPALIVE_TUNABLE
#define NGX_HAVE_KEEPALIVE_TUNABLE  1
#endif


#ifndef NGX_HAVE_TCP_INFO
#define NGX_HAVE_TCP_INFO  1
#endif


#ifndef NGX_HAVE_ACCEPT4
#define NGX_HAVE_ACCEPT4  1
#endif


#ifndef NGX_HAVE_EVENTFD
#define NGX_HAVE_EVENTFD  1
#endif


#ifndef NGX_HAVE_SYS_EVENTFD_H
#define NGX_HAVE_SYS_EVENTFD_H  1
#endif


#ifndef NGX_HAVE_UNIX_DOMAIN
#define NGX_HAVE_UNIX_DOMAIN  1
#endif


#ifndef NGX_PTR_SIZE
#define NGX_PTR_SIZE  4
#endif


#ifndef NGX_SIG_ATOMIC_T_SIZE
#define NGX_SIG_ATOMIC_T_SIZE  4
#endif


#ifndef NGX_HAVE_LITTLE_ENDIAN
#define NGX_HAVE_LITTLE_ENDIAN  1
#endif


#ifndef NGX_MAX_SIZE_T_VALUE
#define NGX_MAX_SIZE_T_VALUE  2147483647L
#endif


#ifndef NGX_SIZE_T_LEN
#define NGX_SIZE_T_LEN  (sizeof("-2147483648") - 1)
#endif


#ifndef NGX_MAX_OFF_T_VALUE
#define NGX_MAX_OFF_T_VALUE  2147483647L
#endif


#ifndef NGX_OFF_T_LEN
#define NGX_OFF_T_LEN  (sizeof("-2147483648") - 1)
#endif


#ifndef NGX_TIME_T_SIZE
#define NGX_TIME_T_SIZE  8
#endif


#ifndef NGX_TIME_T_LEN
#define NGX_TIME_T_LEN  (sizeof("-2147483648") - 1)
#endif


#ifndef NGX_MAX_TIME_T_VALUE
#define NGX_MAX_TIME_T_VALUE  2147483647L
#endif


#ifndef NGX_HAVE_PREAD
#define NGX_HAVE_PREAD  1
#endif


#ifndef NGX_HAVE_PWRITE
#define NGX_HAVE_PWRITE  1
#endif


#ifndef NGX_SYS_NERR
#define NGX_SYS_NERR  135
#endif


#ifndef NGX_HAVE_LOCALTIME_R
#define NGX_HAVE_LOCALTIME_R  1
#endif


#ifndef NGX_HAVE_POSIX_MEMALIGN
#define NGX_HAVE_POSIX_MEMALIGN  1
#endif


#ifndef NGX_HAVE_MEMALIGN
#define NGX_HAVE_MEMALIGN  1
#endif


#ifndef NGX_HAVE_MAP_ANON
#define NGX_HAVE_MAP_ANON  1
#endif


#ifndef NGX_HAVE_MAP_DEVZERO
#define NGX_HAVE_MAP_DEVZERO  1
#endif


#ifndef NGX_HAVE_SYSVSHM
#define NGX_HAVE_SYSVSHM  1
#endif


#ifndef NGX_HAVE_MSGHDR_MSG_CONTROL
#define NGX_HAVE_MSGHDR_MSG_CONTROL  1
#endif


#ifndef NGX_HAVE_FIONBIO
#define NGX_HAVE_FIONBIO  1
#endif


#ifndef NGX_HAVE_GMTOFF
#define NGX_HAVE_GMTOFF  1
#endif


#ifndef NGX_HAVE_D_TYPE
#define NGX_HAVE_D_TYPE  1
#endif


#ifndef NGX_HAVE_SC_NPROCESSORS_ONLN
#define NGX_HAVE_SC_NPROCESSORS_ONLN  1
#endif


#ifndef NGX_HAVE_OPENAT
#define NGX_HAVE_OPENAT  1
#endif


#ifndef NGX_HAVE_GETADDRINFO
#define NGX_HAVE_GETADDRINFO  1
#endif


#ifndef NGX_THREADS
#define NGX_THREADS  1
#endif


#ifndef NGX_HAVE_SELECT
#define NGX_HAVE_SELECT  1
#endif


//#ifndef NGX_HAVE_POLL
//#define NGX_HAVE_POLL  1
//#endif


#ifndef NGX_HTTP_CACHE
#define NGX_HTTP_CACHE  1
#endif


#ifndef NGX_HTTP_GZIP
#define NGX_HTTP_GZIP  1
#endif


#ifndef NGX_HTTP_SSI
#define NGX_HTTP_SSI  1
#endif


#ifndef NGX_HTTP_GZIP
#define NGX_HTTP_GZIP  1
#endif


#ifndef NGX_HTTP_V2
#define NGX_HTTP_V2  1
#endif


#ifndef NGX_HTTP_GZIP
#define NGX_HTTP_GZIP  1
#endif


#ifndef NGX_CRYPT
#define NGX_CRYPT  1
#endif


#ifndef NGX_HTTP_REALIP
#define NGX_HTTP_REALIP  1
#endif


#ifndef NGX_HTTP_X_FORWARDED_FOR
#define NGX_HTTP_X_FORWARDED_FOR  1
#endif


#ifndef NGX_HTTP_X_FORWARDED_FOR
#define NGX_HTTP_X_FORWARDED_FOR  1
#endif


#ifndef NGX_HTTP_SSL
#define NGX_HTTP_SSL  1
#endif


#ifndef NGX_HTTP_X_FORWARDED_FOR
#define NGX_HTTP_X_FORWARDED_FOR  1
#endif


#ifndef NGX_HTTP_UPSTREAM_ZONE
#define NGX_HTTP_UPSTREAM_ZONE  1
#endif


#ifndef NGX_MAIL_SSL
#define NGX_MAIL_SSL  1
#endif


#ifndef NGX_STREAM_SSL
#define NGX_STREAM_SSL  1
#endif


#ifndef NGX_STREAM_UPSTREAM_ZONE
#define NGX_STREAM_UPSTREAM_ZONE  1
#endif


#ifndef NGX_PCRE
#define NGX_PCRE  1
#endif


#ifndef NGX_OPENSSL
#define NGX_OPENSSL  1
#endif


#ifndef NGX_SSL
#define NGX_SSL  1
#endif


#ifndef NGX_HAVE_OPENSSL_MD5_H
#define NGX_HAVE_OPENSSL_MD5_H  1
#endif


#ifndef NGX_OPENSSL_MD5
#define NGX_OPENSSL_MD5  1
#endif


#ifndef NGX_HAVE_MD5
#define NGX_HAVE_MD5  1
#endif


#ifndef NGX_HAVE_OPENSSL_SHA1_H
#define NGX_HAVE_OPENSSL_SHA1_H  1
#endif


#ifndef NGX_HAVE_SHA1
#define NGX_HAVE_SHA1  1
#endif


#ifndef NGX_ZLIB
#define NGX_ZLIB  1
#endif


#ifndef NGX_PREFIX
#define NGX_PREFIX  ""
#endif


#ifndef NGX_CONF_PREFIX
#define NGX_CONF_PREFIX  "conf/"
#endif


#ifndef NGX_SBIN_PATH
#define NGX_SBIN_PATH  "sbin/nginx"
#endif


#ifndef NGX_CONF_PATH
#define NGX_CONF_PATH  "conf/nginx.conf"
#endif


#ifndef NGX_PID_PATH
#define NGX_PID_PATH  ".pid"
#endif


#ifndef NGX_LOCK_PATH
#define NGX_LOCK_PATH  ".lock"
#endif


#ifndef NGX_ERROR_LOG_PATH
#define NGX_ERROR_LOG_PATH  "logs/error.log"
#endif


#ifndef NGX_HTTP_LOG_PATH
#define NGX_HTTP_LOG_PATH  "logs/access.log"
#endif


#ifndef NGX_HTTP_CLIENT_TEMP_PATH
#define NGX_HTTP_CLIENT_TEMP_PATH  "client_body_temp"
#endif


#ifndef NGX_HTTP_PROXY_TEMP_PATH
#define NGX_HTTP_PROXY_TEMP_PATH  "proxy_temp"
#endif


#ifndef NGX_HTTP_FASTCGI_TEMP_PATH
#define NGX_HTTP_FASTCGI_TEMP_PATH  "fastcgi_temp"
#endif


#ifndef NGX_HTTP_UWSGI_TEMP_PATH
#define NGX_HTTP_UWSGI_TEMP_PATH  "uwsgi_temp"
#endif


#ifndef NGX_HTTP_SCGI_TEMP_PATH
#define NGX_HTTP_SCGI_TEMP_PATH  "scgi_temp"
#endif


#ifndef NGX_SUPPRESS_WARN
#define NGX_SUPPRESS_WARN  1
#endif


#ifndef NGX_SMP
#define NGX_SMP  1
#endif


#ifndef NGX_USER
#define NGX_USER  "shell"
#endif


#ifndef NGX_GROUP
#define NGX_GROUP  "shell"
#endif

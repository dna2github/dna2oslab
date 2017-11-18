# How to use getaddrinfo.h

============

in busybox source code

open `nslookup.c` and `xconnect.c`; add `#include "getaddrinfo.h"` under `#include <netdb.h>`

make busybox statically

`nslookup` `wget` `ping` will work without glibc

============

in nodejs source code

open `deps/uv/src/unix/getaddrinfo.c`; add `#include "getaddrinfo.h"` under `#include <netdb.h>`

make nodejs fully statically

node will work without glibc; exactly `npm install` works

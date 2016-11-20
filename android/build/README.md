Android Platform Lab

> Android 6 only supports binaries with PIE enabled

Binary Test Machine:
  Huawei Honor 5A (Android 6.0)

Lab:
- compile binaries
    - nginx-1.9.5 (nginx-1.9.5-pie.sh) with [How to use compiled Nginx in APK](https://github.com/dna2github/dna2mtgol/tree/master/fileShare)
    - python-2.7.8
    - node-v4.4.4
    - node-v6.5.0
    - node-v7.1.0

> Android &lt;5

- Machine Configuration:
  - Linux 64-bits
  - Google Android NDK

- Binary Test Machine:
  - Redmi Note (Android 4.4)
  - Huawei Y511 (Android 4.2)
  - HTC G7 (Android 2.2)

Lab:
- compile libraries
    - openssl-1.0.1j
    - ncurses-5.7
    - zlib-1.2.8
    - pcre-8.37
    - readline-6.3
- compile binaries
    - tar-1.27
    - vim-7.4
    - wget-1.16
    - binutils-2.24
    - sqlite-autoconf-3080701
    - python-2.7.8 => (pip => django gevent-socketio2 numpy)
    - node-v0.12.6
    - node-v4.4.4
    - nginx-1.9.5

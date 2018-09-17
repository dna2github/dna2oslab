#/bin/bash
set -xe

MEDIR=$(cd `dirname $0`; pwd)
ME=haproxy-1.7.1

cd $MEDIR
source env.sh
source common.sh

cd ..
rm -rf $ME
fetch_source $ME.tar.gz http://www.haproxy.org/download/1.7/src/haproxy-1.7.1.tar.gz
tar zxf $SRCTARBALL/$ME.tar.gz
cd $ME
mkdir -p dist

sed -i "s|^PREFIX = .*$|PREFIX = $MEDIR/../$ME/dist|" Makefile
grep sys/select.h include/common/config.h || echo "#include <sys/select.h>" >> include/common/config.h
cat >> $MEDIR/../$ME/include/common/config.h <<EOF
/*
 * include/common/config.h
 * This files contains most of the user-configurable settings.
 *
 * Copyright (C) 2000-2009 Willy Tarreau - w@1wt.eu
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation, version 2.1
 * exclusively.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

#ifndef _COMMON_CONFIG_H
#define _COMMON_CONFIG_H

#include <common/compiler.h>
#include <common/compat.h>
#include <common/defaults.h>

/* this reduces the number of calls to select() by choosing appropriate
 * sheduler precision in milliseconds. It should be near the minimum
 * time that is needed by select() to collect all events. All timeouts
 * are rounded up by adding this value prior to pass it to select().
 */
#define SCHEDULER_RESOLUTION    9

/* CONFIG_HAP_MEM_OPTIM
 * This enables use of memory pools instead of malloc()/free(). There
 * is no reason to disable it, except perhaps for rare debugging.
 */
#ifndef   CONFIG_HAP_NO_MEM_OPTIM
#  define CONFIG_HAP_MEM_OPTIM
#endif /* CONFIG_HAP_NO_MEM_OPTIM */

/* CONFIG_HAP_MALLOC / CONFIG_HAP_CALLOC / CONFIG_HAP_FREE
 * This macro allows to replace the malloc function with another one.
 */
#ifdef CONFIG_HAP_MALLOC
#define MALLOC	CONFIG_HAP_MALLOC
#else
#define MALLOC	malloc
#endif

#ifdef CONFIG_HAP_CALLOC
#define CALLOC	CONFIG_HAP_CALLOC
#else
#define CALLOC	calloc
#endif

#ifdef CONFIG_HAP_FREE
#define FREE	CONFIG_HAP_FREE
#else
#define FREE	free
#endif


/* CONFIG_HAP_INLINE_FD_SET
 * This makes use of inline FD_* macros instead of calling equivalent
 * functions. Benchmarks on a Pentium-M show that using functions is
 * generally twice as fast. So it's better to keep this option unset.
 */
//#undef  CONFIG_HAP_INLINE_FD_SET

#endif /* _COMMON_CONFIG_H */
#include <sys/select.h>

EOF
make TARGET=generic PREFIX=$MEDIR/../$ME/dist CC="$CC --sysroot=$ANDROID -I$ANDROID/include -L$ANDROID/lib $PIEFLAG"
make_install $ME

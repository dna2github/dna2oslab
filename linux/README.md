```shell
KERNEL_SRC=https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.14.tar.xz
BUSYBOX_SRC=https://busybox.net/downloads/busybox-1.27.2.tar.bz2

wget $BUSYBOX_SRC
tar jxf busybox-<version>.tar.bz2 && cd busybox-<version>
# interactive; check static binary option
make menuconfig
make SHELL="$SHELL -x" | tee build.log

wget $KERNEL_SRC
tar Jxf linux-<version>.tar.xz && cd linux-<version>
make defaultconfig
make pkg-tar SHELL="$SHELL -x" | tee build.log

# learn for existing initrd
mkdir initrd_learn && cd initrd_learn
zcat /boot/initrd-2.6.18-164.6.1.el5.img | cpio -idmv
# repack initrd; "gzip", "bzip2", or "xz -9 --format=lzma"
find . | cpio -o -c | gzip -9 > new_initrd.img

# mknod --help
mkdir initrd && cd initrd
mkdir bin sbin dev tmp proc var etc sys
mknod dev/
cp -r /path/to/kernel/* ./
cp /path/to/busybox bin/busybox
ln -s ./bin/busybox init
ln -s busybox bin/sh
ln -s busybox bin/bash
ln -s busybox bin/ls
ln -s busybox bin/chmod
ln -s busybox bin/mount
ln -s busybox bin/mv
ln -s busybox bin/ln
ln -s busybox bin/cp
ln -s busybox bin/rm
ln -s busybox bin/mkdir
ln -s busybox bin/mknod
ln -s busybox bin/grep
ln -s busybox bin/find
ln -s busybox bin/vi
ln -s busybox bin/less
ln -s busybox bin/touch
ln -s ../bin/busybox sbin/init
ln -s ../bin/busybox sbin/reboot
ln -s ../bin/busybox sbin/poweroff
ln -s ../bin/busybox sbin/ip
ln -s ../bin/busybox sbin/ifconfig

mknod dev/mem c 1 1
mknod dev/null c 1 3
mknod dev/port c 1 4
mknod dev/zero c 1 5
mknod dev/random c 1 8
mknod dev/urandom c 1 9
mknod dev/kmsg c 1 11
mknod dev/tty0 c 4 0
mknod dev/tty1 c 4 1
mknod dev/tty2 c 4 2
mknod dev/tty3 c 4 3
mknod dev/tty4 c 4 4
mknod dev/tty5 c 4 5
mknod dev/tty6 c 4 6
mknod dev/tty7 c 4 7
mknod dev/tty c 5 0
mknod dev/console c 5 1
mknod dev/ptmx c 5 2
mknod dev/loop0 b 7 0
mknod dev/sda b 8 0
mknod dev/sr0 b 11 0


# test on qemu
qemu-system-x86_64 -m 1024m -curses -kernel boot/vmlinuz-<version> -initrd boot/test.initrd -append noapic


# disk boot
dd if=/dev/zero of=disk.img bs=<size> count=1
mkfs.ext2 disk.img
mkdir disk
mount disk.img disk
echo do ln, mknod and tar xf linux-<version>.tar; rm -rf lib boot/vmlinux-<version>
LOID=$(losetup -f --show disk.img)
# if meet `error: embedding is not possible, but this is required for cross-disk install.`
# please download grub source code and compile it
# modify grub-core/gnulib/stdio.h: #undef gets => #undef gets \n #define gets fgets
# modify utils/grub-setup.c: comment out the if clause within the string containning `embedding is not possible`
# ./configure --disable-werror && make
grub2-install --force --root-directory=./disk $LOID
losetup -d $LOID
umount disk

qemu-system-x86_64 -m 1024m -curses -hda disk.img
>> linux /boot/vmlinuz-<version> noapic
>> initrd /boot/test.initrd
>> boot

mount proc /proc -t proc
mount sys /sys -t sysfs
mount dev /dev -t devtmpfs
mount tmp /tmp -t tmpfs

ifconfig eth0 <ip> netmask 255.255.255.0 up
ip route add default via <ip> dev eth0

```
